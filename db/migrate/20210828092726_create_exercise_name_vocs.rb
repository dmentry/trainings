class CreateExerciseNameVocs < ActiveRecord::Migration[6.0]
  def change
    create_table :exercise_name_vocs do |t|
      t.string :label

      t.timestamps
    end
  end
end
