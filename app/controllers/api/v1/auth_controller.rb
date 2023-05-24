# frozen_string_literal: true

require 'securerandom'

module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authorized, only: %i[login request_code verify]

      def login
        @user = User.find_by(email: user_params[:email])

        if user_params[:email].blank? || user_params[:password].blank?
          render json: { errors: ['Email or password cannot be blank.'] }, status: :unprocessable_entity

        elsif @user&.authenticate(user_params[:password])

          if @user.verified
            login_status = @user.login!
            @user.save
            render json: login_status, status: :ok
          else
            render json: { errors: ['Account must be verified before logging in'] }, status: :unprocessable_entity
          end

        else
          render json: { errors: ['Incorrect email or password.'] }, status: :unprocessable_entity
        end
      end

      def logout
        @user = current_user
        if @user

          if @user.logout!
            render json: { messages: ['User logged out successfully'] }, status: :ok
          else
            render json: { errors: ['Logout unsuccessful, please try again.'] }, status: :unprocessable_entity
          end

        else
          render json: { errors: ['User not found.'] }, status: :unprocessable_entity

        end
      end

      def request_code
        @user = User.find_by(email: params[:email])
        if @user
          @user.request_code(params[:request])
          render json: { messages: ["#{params[:request]} code sent to #{@user.email}"] }, status: :ok
        else
          render json: { errors: ['Email not registered.'] }, status: :unprocessable_entity
        end
      end

      def verify
        @user = User.find_by(email: params[:email])
        if @user
          status = @user.verify_code(params[:request], params[:code], params[:password])
          render json: status[:response], status: status[:status]
        else
          render json: { errors: ['User not found']}, status: :unprocessable_entity
        end
      end


      private

      def user_params
        params.require(:user).permit(:email, :password)
      end
    end
  end
end
