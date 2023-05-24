# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :authorized

  def current_user
    return nil unless decoded_token
    return nil if decoded_token['exp'] < Time.now.to_i

    @user = User.find_by(unique_id: decoded_token['id'])
    return nil unless @user

    @user.validate_jti(decoded_token['jti'])
  end

  def logged_in?
    !!current_user
  end

  def authorized
    return if logged_in?

    render json: { errors: ['Token invalid. Please log in.'] }, status: :not_found
  end

  private

  def decoded_token
    auth_header = request.headers['Authorization']
    return nil unless auth_header

    secret_key = Rails.application.credentials.jwt.secret_key
    JWT.decode(auth_header, secret_key, true, algorithm: 'HS256')[0]
  end
end
