class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.string :unique_id
      t.string :title
      t.string :body
      t.string :status

      t.timestamps
    end
  end
end
