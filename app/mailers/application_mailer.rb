# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'admin@letter-heals.org'
  layout 'mailer'
end
