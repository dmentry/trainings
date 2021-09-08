class CreateTrainings < ActiveRecord::Migration[6.0]
  def change
    create_table :trainings do |t|
      t.string :label
      t.date :start_time

      t.timestamps
    end

    add_reference :trainings, :user, null: false, foreign_key: true
  end
end
