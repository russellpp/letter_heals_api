# frozen_string_literal: true

class User
  module Verification
    def request_code(type)
      new_code = generate_code
      cache_code(type, new_code)
      code = Rails.cache.read("#{type}_code_for_#{self.email}")
      UserMailer.request_code(self, code, type).deliver_now
    end

    def verify_code(type, code, password)
      cached_code = Rails.cache.read("#{type}_code_for_#{self.email}")
      if cached_code.nil?
        request_code(type)
        {response: {errors: ["Code expired, new #{type} code sent to #{self.email}"]}, status: :unprocessable_entity}
      elsif code.to_i == cached_code
        if type == 'verification'
          self.verify!
          {response: {messages: ["Your account registered with #{self.email} has been verified, you are now able to login and join the Letter Heals Community."]}, status: :ok}
        else
          self.update_password(password)
          {response: {messages: ["Your password has been reset."]}, status: :ok}
        end     
      else
        {response: {errors: ["Incorrect code."]}, status: :unprocessable_entity}
      end       
      
    end

    private

    def generate_code
      rand(100_000..999_999)
    end

    def cache_code(type, code)
      Rails.cache.write("#{type}_code_for_#{self.email}", code, expires_in: 5.minutes)
    end
  end
end
