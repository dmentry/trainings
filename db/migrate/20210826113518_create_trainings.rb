class CreateTrainings < ActiveRecord::Migration[6.0]
  def change
    create_table :trainings do |t|
      t.string :label
      t.datetime :training_dt

      t.timestamps
    end
  end
end
