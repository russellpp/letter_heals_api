# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer
  attributes :id, :unique_id, :email, :phone_number, :verified, :profile_name
end
