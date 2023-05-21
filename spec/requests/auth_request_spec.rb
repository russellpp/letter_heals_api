# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

RSpec.describe Api::V1::AuthController, type: :controller do
  # #login
  describe 'POST #login' do
    before do
      request.headers['Content-Type'] = 'application/json'
    end

    let(:user_params) do
      {
        user: {
          email: user.email,
          password: user.password
        }
      }
    end

    context 'and the user has not logged out last session' do
      let(:user) { create(:user, :not_logged_out) }
      let(:current_jti) { 'a45f8b7d75e57cc4' }

      it 'logs out the user and creates new jti' do
        user = create(:user, :not_logged_out)

        post :login, params: user_params

        expect(user.jti).not_to eq(current_jti)

        expect(user.status).to eq(1)
      end
    end

    context 'when logging in and params are valid' do
      let(:current_jti) { SecureRandom.hex(16).to_s }
      let(:user) { create(:user, :logged_out, attributes_for(:user).merge(jti: current_jti)) }


      context 'but the user is not verified' do
        let(:user) { create(:user, :unverified) }

        it 'returns an error message' do
          post :login, params: user_params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to include(
            'errors' => ['Account must be verified before logging in']
          )
        end
      end

      it 'and returns a success message' do
        post :login, params: user_params
        expect(user.jti).to eq(current_jti)
        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body).to include(
          'messages' => ['User logged in.'],
          'user' => {
            'email' => user.email,
            'id' => user.id,
            'name' => user.name,
            'phone_number' => user.phone_number,
            'profile_name' => user.profile_name,
            'status' => 1,
            'unique_id' => user.unique_id,
            'verified' => user.verified
          }
        )
        token = JSON.parse(response.body)['token']
        puts token
        secret_key = Rails.application.credentials.jwt.secret_key
        payload = JWT.decode(token, secret_key, true, algorithm: 'HS256')[0]
        expect(payload['exp']).to be_within(1).of(Time.now.to_i + 30 * 60)
        expect(payload['id']).to eq(user.unique_id)
        expect(payload['jti']).to eq(current_jti)
      end
    end

    context 'when logging in and params are invalid' do
      let(:user_params) do
        {
          user: {
            email: '',
            password: ''
          }
        }
      end

      it 'returns an error message' do
        post :login, params: user_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include(
          'errors' => ['Email or password cannot be blank.']
        )
      end
    end

    context ': the password or email is invalid' do
      let(:user_params) do
        { user: {
          email: 'random@email.com',
          password: 'notarealpassword'
        } }
      end

      it 'returns a an error message' do
        post :login, params: user_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include(
          'errors' => ['Incorrect email or password.']
        )
      end
    end
  end

  # logout
  describe 'PUT #logout' do
    let(:user) { create(:user, :not_logged_out) }
    let(:secret_key) {Rails.application.credentials.jwt.secret_key}
    let (:authorization) {JWT.encode({id: user.unique_id, exp: Time.now.to_i + 30 * 60, jti: user.jti}, Rails.application.credentials.jwt.secret_key, 'HS256')}

    before do
      request.headers['Content-Type'] = 'application/json'
      request.headers['Authorization'] = "#{authorization}"
    end

    context 'and is successful ' do 
     
      
      it 'changes user status and creates new jti' do
          puts "user #{user.id} #{user.unique_id} #{user.email}"
          puts authorization
          put :logout
          expect(JSON.parse(response.body)).to include(
            'messages' => ['User logged out successfully']
          )
          expect(response).to have_http_status(:ok)
          
        end
     
      
    
    end
  
  end


end
