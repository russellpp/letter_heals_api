# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      def create
        @user = User.create(user_params)

        if @user.save

          render json: { messages: ['Account successfully created.'], user: UserCreateSerializer.new(@user) },
                 status: :ok

        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation, :phone_number)
      end
    end
  end
end
