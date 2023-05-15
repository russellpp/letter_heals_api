class AddForeignKeys < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :recipient, :string
    add_foreign_key :messages, :users, column: :recipient, primary_key: :unique_id

    add_column :posts, :author, :string
    add_foreign_key :posts, :users, column: :author, primary_key: :unique_id
    add_column :posts, :reviewer, :string
    add_foreign_key :posts, :users, column: :reviewer, primary_key: :unique_id
  end
end
