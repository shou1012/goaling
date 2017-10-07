class CreateNotification < ActiveRecord::Migration[5.1]
  def change
    create_table :notifications do |t|
      t.string :status
      t.references :user
      t.references :goal
      t.integer :victim_id
      t.timestamps null: false
    end
  end
end
