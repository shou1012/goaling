class CreateGoals < ActiveRecord::Migration[5.1]
  def change
    create_table :goals do |t|
        t.references :user
        t.string :title
        t.integer :favorite
        t.timestamps null: false
    end
  end
end
