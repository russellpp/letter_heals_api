# frozen_string_literal: true

class AddVerifiedToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :verified, :boolean
  end
end
