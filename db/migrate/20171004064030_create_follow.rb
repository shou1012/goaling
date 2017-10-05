class CreateFollow < ActiveRecord::Migration[5.1]
  def change
    create_table :follows do |t|
      t.references :user
      t.integer :follower_id
    end
  end
end
