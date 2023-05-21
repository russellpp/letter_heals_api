# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'passworD#12345' }
    password_confirmation { 'passworD#12345' }
    phone_number { "+639456#{rand(100_000..999_999)}" }
    status { 0 }

    trait :not_logged_out do
      verified { true }
      status { 1 }
    end

    trait :logged_out do
      verified { true }
      status { 0 }
    end

    trait :unverified do
      verified { false }
      status { 0 }
    end

    trait :invalid_login do
      verified { true }
      status { 0 }
    end
  end
end
