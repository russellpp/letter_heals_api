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
    let(:secret_key) { Rails.application.credentials.jwt.secret_key }
    let(:authorization) do
      JWT.encode({ id: user.unique_id, exp: Time.now.to_i + 30 * 60, jti: user.jti },
                 Rails.application.credentials.jwt.secret_key, 'HS256')
    end

    before do
      request.headers['Content-Type'] = 'application/json'
      request.headers['Authorization'] = authorization.to_s
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

  describe 'POST #request_code' do
    let(:user) { create(:user, :unverified) }

    context 'requests for a code for verification' do
      let(:request_params) do
        {
          request: 'verification',
          email: user.email
        }
      end
      let(:code) { 123456 }

      before do
        allow_any_instance_of(User).to receive(:generate_code).and_return(code)
        post :request_code, params: request_params
      end

      it 'generates a code and sends it to email' do
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include(
          'messages' => ["verification code sent to #{user.email}"]
        )
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        email = ActionMailer::Base.deliveries.last
        html_content = email.body.encoded
        expect(email.to).to include(user.email)
        expect(email.subject).to eq('Email Verification')
        expect(html_content).to include('<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />')
        expect(html_content).to include('<h1>Email Verification</h1>')
        expect(html_content).to include("<p>Hello #{user.name},</p>")
        expect(html_content).to include('<p>Please verify your email address by clicking the following link or entering the 6-digit code:</p>')
        expect(html_content).to include("<a href=\"http://127.0.0.1:3000/api/v1/auth/verify?email=#{user.email}&amp;code=#{code}&amp;request=verification\">Verify Email</a>")
      end
    end

    context 'requests for a code for password reset' do
      let(:request_params) do
        {
          request: 'reset',
          email: user.email
        }
      end
      let(:code) { 123456 }

      before do
        allow_any_instance_of(User).to receive(:generate_code).and_return(code)
        post :request_code, params: request_params
      end

      it 'generates a code and sends it to email' do
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include(
          'messages' => ["reset code sent to #{user.email}"]
        )
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        email = ActionMailer::Base.deliveries.last
        html_content = email.body.encoded
        expect(email.to).to include(user.email)
        expect(email.subject).to eq('Confirm Password Reset')
        expect(html_content).to include('<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />')
        expect(html_content).to include('<h1>Password reset</h1>')
        expect(html_content).to include("<p>Hello #{user.name},</p>")
        expect(html_content).to include('<p>Please confirm password reset by entering the 6-digit code:</p>')
        expect(html_content).to include("<p>#{code}</p>")
      end
    end

    context 'requests for a code but account does not exist' do
      let(:request_params) do
        {
          request: 'verification',
          email: 'some.random.email@doesnotexist.co'
        }
      end
      

      before do
        post :request_code, params: request_params
      end

      it 'sends an error message' do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include(
          'errors' => ['Email not registered.']
        )
      end
    end
  end

  describe 'POST #verify' do
    let(:user) { create(:user, :unverified) }

    context 'when incorrect email is in params' do
      let(:verify_params) do 
        {
        request: 'verification',
        email: 'some.random@email.org',
        code: 123456
        }
      end
      let(:code) { 123456 }
      
      before do
        post :verify, params: verify_params
      end

      it 'returns an error message' do
      
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to include(
        'errors' => ['User not found']
      )
      end
    end

    context 'when code is expired' do
      let(:verify_params) do 
        {
        request: 'verification',
        email: user.email,
        code: 123456
      }
      end

      before do
        allow(Rails.cache).to receive(:read).and_return(nil)
        post :verify, params: verify_params
      end
    
      it 'returns an error and sends another code' do 
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include(
          'errors' => ["Code expired, new verification code sent to #{user.email}"]
        )
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        email = ActionMailer::Base.deliveries.last
        html_content = email.body.encoded
        expect(email.to).to include(user.email)
        expect(email.subject).to eq('Email Verification')
      end
    end

    context 'when code is incorrect' do
      let(:code) { 123456 }
      let(:verify_params) do 
        {
        request: 'verification',
        email: user.email,
        code: 999666
      }
      end

      before do
        allow(Rails.cache).to receive(:read).and_return(code)
        post :verify, params: verify_params
      end
    
      it 'returns an error' do 
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include(
          'errors' => ["Incorrect code."]
        )
       
      end
    end

    context 'when all params are correct for verification' do
      let(:code) { 123456 }
      let(:verify_params) do 
        {
        request: 'verification',
        email: user.email,
        code: code
      }
      end

      before do
        allow(Rails.cache).to receive(:read).and_return(code)
      end
      
      it 'sets the user verified status to true returns a success message' do 
        
        expect(user.verified).to eq(false)
        
        post :verify, params: verify_params

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include(
          'messages' => ["Your account registered with #{user.email} has been verified, you are now able to login and join the Letter Heals Community."]
        )
        
      end
    end

    context 'when all params are correct for password reset' do
      let(:code) { 123456 }
      let(:reset_params) do 
        {
        request: 'reset',
        email: user.email,
        code: code,
        password: 'newPaSSW0rd123aBc'
      }
      end

      before do
        allow(Rails.cache).to receive(:read).and_return(code)
      end
      
      it 'changes the password and returns a success message' do 
        
        
        post :verify, params: reset_params
        user.reload
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include(
          'messages' => ["Your password has been reset."]
        )
        expect {
          user.update_password('newPaSSW0rd123aBc')
        }.to change { user.reload.authenticate('newPaSSW0rd123aBc') }.from(false).to(user)
        
      end
    end

  end
end
