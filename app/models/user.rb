# frozen_string_literal: true

require 'uuidtools'
require 'securerandom'

class User < ApplicationRecord
  has_secure_password

  has_many :authored_messages, class_name: 'Message', foreign_key: :author, dependent: :destroy
  has_many :received_messages, class_name: 'Message', foreign_key: :recipient, dependent: :destroy
  has_many :authored_posts, class_name: 'Post', foreign_key: :author, dependent: :destroy
  has_many :reviewed_posts, class_name: 'Post', foreign_key: :reviewer, dependent: :destroy

  validates :unique_id, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true,
                    format: { with: /\A[\w+\-.]+@[a-z\d-]+(\.[a-z]+)*\.[a-z]+\z/i, message: 'is in invalid format.' }
  validates :phone_number, presence: true, uniqueness: true,
                           format: { with: /\A\+639\d{9}\z/i, message: 'is an invalid number.' }
  validates :status, presence: true, inclusion: { in: [0, 1] }
  validates :role, presence: true, inclusion: { in: %w[admin moderator user] }
  validates :name, presence: true
  validates :jti, presence: true, uniqueness: true
  validates :profile_name, presence: true
  validates :verified, inclusion: { in: [true, false] }

  validates :password, presence: true, length: { minimum: 8 }
  validates :password_confirmation, presence: true

  validate :password_format_validation

  before_validation :set_defaults, on: :create

  def login!

    if status == 1
      logout!
    end 
    self.status = 1
    save

    token = self.encode_token
    messages = { messages: ['User logged in.'], user: UserSerializer.new(self), token: token }
    
  end

  def logout!
    self.status = 0
    self.jti = SecureRandom.hex(16).to_s
    save
    return true
  end

  def validate_jti(jti)
    if jti == self.jti
      return self
    else
      return nil
    end
    
  end

  private

  def set_defaults
    self.unique_id ||= UUIDTools::UUID.random_create.to_s
    self.jti ||= SecureRandom.hex(16).to_s
    self.verified ||= false
    self.status ||= 0
    self.role ||= 'user'
    self.profile_name ||= email
    self.name ||= email
  end

  def password_format_validation
    return unless password.present?

    return if password.match?(/\W/) && password.match?(/\d/) && password.match?(/[a-z]/) && password.match?(/[A-Z]/)

    errors.add(:password,
               'must contain at least one special character, one number, one lowercase letter and one uppercase letter.')
  end

  def secret_key
    Rails.application.credentials.jwt.secret_key
  end

  def encode_token
    expiry = Time.now.to_i + 30 * 60
    payload = { id: self.unique_id, jti: self.jti, exp: expiry }
    JWT.encode(payload, secret_key, 'HS256')
  end

  # def decode_token(payload)
  #   SECRET_KEY = Rails.application.credentials.jwt.secret_key
  #   JWT.decode(token, SECRET_KEY, true, algorithm: 'HS256')
  # end
end
