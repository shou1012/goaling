class UpdateGoals < ActiveRecord::Migration[5.1]
  def change
    change_column :goals, :favorite, :integer, default: 0
  end
end
