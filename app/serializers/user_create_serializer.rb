# frozen_string_literal: true

class UserCreateSerializer < ActiveModel::Serializer
  attributes :email, :phone_number, :verified
end
