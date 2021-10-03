class AddExpLevelNextLevelToTables < ActiveRecord::Migration[6.0]
  def change
    add_column :exercise_name_vocs, :exp, :bigint, default: 0
    add_column :exercises, :level, :bigint, default: 1
    add_column :exercises, :next_level_exp, :bigint, default: 0
    add_column :users, :money, :float, default: 0
    add_column :users, :rank, :string
  end
end
