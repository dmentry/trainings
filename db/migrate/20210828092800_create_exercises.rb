class CreateExercises < ActiveRecord::Migration[6.0]
  def change
    create_table :exercises do |t|
      t.string :quantity
      t.text :note
      t.float :summ

      t.references :training, null: false, foreign_key: true
      t.references :exercise_name_voc, null: false, foreign_key: true

      t.timestamps
    end
  end
end
