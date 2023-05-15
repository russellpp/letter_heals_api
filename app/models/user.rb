require 'uuidtools'
require 'securerandom'

class User < ApplicationRecord
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

  before_create :set_defaults

  private

  def set_defaults
    self.unique_id ||= UUIDTools::UUID.random_create.to_s
    self.jti ||= SecureRandom.hex(16).to_s
    self.verified ||= false
    self.status ||= 0
    self.role ||= 'user'
  end
end
