class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :unique_id
      t.string :email
      t.string :phone_number
      t.integer :status
      t.string :name

      t.timestamps
    end
  end
end
