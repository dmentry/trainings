module TrainingsHelper
  class TrainingExport
    def self.download_textfile(current_user)
      @current_user = current_user

      trainings = @current_user.trainings.all

      tr = ''

      trainings.find_all do |training|
        tr << training.label << "\n"

        training.exercises.find_all do |exercise|
          tr << exercise.exercise_name_voc.label << ": "

          tr << exercise.quantity << "\n"

          tr << "Общее количество: "

          if exercise.exercise_name_voc.label.match?(/бег|лыжи|Бег|Лыжи/)
            tr << exercise.summ.to_s << "\n"   
          else
           tr << exercise.summ.to_i.to_s << "\n"
          end

          tr << exercise.note << "\n"
        end
      end
      
      tr
    end
  end
end
