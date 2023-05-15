class AddReferencesToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :author, :string
    add_foreign_key :messages, :users, column: :author, primary_key: :unique_id
  end
end
