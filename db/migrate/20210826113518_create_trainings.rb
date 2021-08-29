class CreateTrainings < ActiveRecord::Migration[6.0]
  def change
    create_table :trainings do |t|
      t.string :label
      t.date :start_time

      t.timestamps
    end
  end
end
