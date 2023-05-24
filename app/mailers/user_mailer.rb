# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def request_code(user, code, type)
    @user = user
    @code = code
    if type == 'verification'
      mail(to: user.email, subject: 'Email Verification') do |format|
        format.html { render 'request_code' }
      end
    else
      mail(to: user.email, subject: 'Confirm Password Reset') do |format|
        format.html { render 'reset_code' }
      end
    end
  end

  def test_email(email)
    mail(to: email, from: 'letterheals.test001@gmail.com', subject: 'Email Verification') do |format|
      format.text { render plain: 'Test email.' }
    end
  end
end
