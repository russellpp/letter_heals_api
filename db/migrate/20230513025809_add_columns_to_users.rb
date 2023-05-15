class AddColumnsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :jti, :string
    add_column :users, :profile_name, :string
  end
end
