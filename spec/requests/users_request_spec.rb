# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  # #register
  describe 'POST #create' do
    before do
      request.headers['Content-Type'] = 'application/json'
    end

    context 'when params are valid' do
      let(:user_params) do
        {
          user: {
            email: 'russell@gmail.com',
            phone_number: '+639456421993',
            password: 'passworD$12345',
            password_confirmation: 'passworD$12345'
          }
        }
      end

      it 'creates a new user' do
        post :create, params: user_params
        expect(response).to have_http_status(:ok)
        expect(User.count).to eq(3)
        expect(User.last.email).to eq(user_params[:user][:email])
        expect(User.last.name).to eq(user_params[:user][:email])
        expect(User.last.profile_name).to eq(user_params[:user][:email])
        expect(User.last.unique_id).not_to be_nil
        expect(User.last.jti.length).to eq(32)
        expect(User.last.role).to eq('user')
        expect(User.last.status).to eq(0)
        expect(User.last.verified).to eq(false)
        expect(JSON.parse(response.body)).to include(
          'messages' => ['Account successfully created.'],
          'user' => {

            'email' => user_params[:user][:email],
            'phone_number' => user_params[:user][:phone_number],
            'verified' => false
          }
        )
      end
    end

    context 'when params are invalid' do
      context ': email is in not in proper format' do
        let(:user_params) do
          {
            user: {
              email: 'russell@com',
              phone_number: '+639456421993',
              password: 'passworD$12345',
              password_confirmation: 'passworD$12345'
            }
          }
        end

        it 'does not create a user and returns an error message' do
          post :create, params: user_params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(User.count).to eq(2)
          expect(JSON.parse(response.body)).to include(
            'errors' => ['Email is in invalid format.']
          )
        end
      end

      context ': passwords do not match' do
        let(:user_params) do
          {
            user: {
              email: 'russell@gmail.com',
              phone_number: '+639456421993',
              password: 'passworD$12345',
              password_confirmation: 'notapassword17890'
            }
          }
        end

        it 'does not create a user and returns an error message' do
          post :create, params: user_params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(User.count).to eq(2)
          expect(JSON.parse(response.body)).to include(
            'errors' => ["Password confirmation doesn't match Password"]
          )
        end
      end

      context ': password is not in required format' do
        let(:user_params) do
          {
            user: {
              email: 'russell@gmail.com',
              phone_number: '+639456421993',
              password: 'passwordeeee',
              password_confirmation: 'passwordeeee'
            }
          }
        end

        it 'does not create a user and returns an error message' do
          post :create, params: user_params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(User.count).to eq(2)
          expect(JSON.parse(response.body)).to include(
            'errors' => ['Password must contain at least one special character, one number, one lowercase letter and one uppercase letter.']
          )
        end
      end

      context ': phone number is in wrong format' do
        let(:user_params) do
          {
            user: {
              email: 'russell@gmail.com',
              phone_number: '+123456789',
              password: 'passworD$12345',
              password_confirmation: 'passworD$12345'
            }
          }
        end

        it 'does not create a user and returns an error message' do
          post :create, params: user_params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(User.count).to eq(2)
          expect(JSON.parse(response.body)).to include(
            'errors' => ['Phone number is an invalid number.']
          )
        end
      end
    end
  end
end
