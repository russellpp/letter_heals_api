# frozen_string_literal: true

class ApplicationController < ActionController::API

    before_action :authorized 

    
    def current_user
        if decoded_token
            if decoded_token['exp'] < Time.now.to_i
                return nil
            else
                @user = User.find_by(unique_id: decoded_token['id'])
                if @user 
                    @user.validate_jti(decoded_token['jti'])
                else
                    return nil
                end
            end
        else
            return nil
        end
    end

    def logged_in?
        !!current_user
    end

    def authorized
        unless logged_in?
            render json: {errors: ['Token invalid. Please log in.']}, status: :not_found 
        end
    end

    private
    
    def decoded_token
        auth_header = request.headers['Authorization']
        if auth_header
            secret_key = Rails.application.credentials.jwt.secret_key
            payload = JWT.decode(auth_header, secret_key, true, algorithm: 'HS256')[0]
            return payload
        else 
            return nil
        end
    end
    
    


    


end
