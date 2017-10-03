class CreateCheck < ActiveRecord::Migration[5.1]
  def change
    create_table :checks do |c|
      c.references :goal
      c.datetime :checked_time
    end
  end
end
