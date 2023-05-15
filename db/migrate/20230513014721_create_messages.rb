class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.string :unique_id
      t.string :title
      t.string :body
      t.boolean :anonymous

      t.timestamps
    end
  end
end
