module StatisticsHelper
  def self.main_stat_helper(current_user, exercise_name_id)
    # массив всех уникальных упражнений пользователя [id, название], если одинаковых упражнений > 1
    exercises_list = []

    ExerciseNameVoc.where(user_id: current_user.id).each do |exercise|
      exercises_list << [exercise.id, exercise.label] if current_user.exercises.where(exercise_name_voc_id: exercise.id).count > 1
    end

    exercises_list.uniq! {|e| e.second} 

    exercises_list.sort_by!{ |h| h.first }

    data = []

    exercise_name_id.present? ? id = exercise_name_id.to_i : id = current_user.exercises.first.exercise_name_voc_id

    name = Exercise&.find_by(exercise_name_voc: id)&.exercise_name_voc&.label

    current_user.trainings.each do |training|
      training.exercises.each do |exercise|
        data << [training.start_time, exercise.summ] if exercise.exercise_name_voc_id == id
      end
    end

   # data = Exercise.where('exercise_name_voc_id =? AND training_id = ?', id, current_user.training_ids)


    data.to_a.sort_by!{ |h| h.first }

    [data, exercises_list, name]
  end
end