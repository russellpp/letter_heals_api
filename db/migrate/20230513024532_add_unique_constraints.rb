class AddUniqueConstraints < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :unique_id, unique: true
    add_index :messages, :unique_id, unique: true
    add_index :posts, :unique_id, unique: true
  end
end
