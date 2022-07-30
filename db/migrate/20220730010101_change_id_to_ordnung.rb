class ChangeIdToOrdnung< ActiveRecord::Migration[6.0]
  def change
    Training.all.each do |training|
      i = 0
      training.exercises.each do |exercise|
        exercise.update_column(:ordnung, i)

        i += 1
      end
    end
  end
end
