# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def verification_email(user)
    @user = user
    mail(to: user.email, subject: 'Email Verification')
  end

  def test_email(email)
    mail(to: email, from: 'letterheals.test001@gmail.com', subject: 'Email Verification') do |format|
      format.text { render plain: 'Test email.' }
    end
  end
end
