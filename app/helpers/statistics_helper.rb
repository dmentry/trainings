module StatisticsHelper
  def self.main_stat_helper(current_user, exercise_name_id)
    uniq_exercises ||= current_user.exercises.all.map do |exercise| 
      exercise.exercise_name_voc.label if current_user.exercises.where(exercise_name_voc_id: exercise.exercise_name_voc_id).count > 1
    end

    uniq_exercises.compact!.uniq!

    exercises_list = []

    ExerciseNameVoc.where(user_id: current_user.id).each do |exercise|
      exercises_list << [exercise.id, exercise.label] if uniq_exercises&.include?(exercise.label)
    end

    exercises_list.sort_by!{ |h| h.first }

    data = []

    exercise_name_id.present? ? id = exercise_name_id.to_i : id = current_user.exercises.first.exercise_name_voc_id

    name = Exercise&.find_by(exercise_name_voc: id)&.exercise_name_voc&.label

    current_user.trainings.each do |training|
      training.exercises.each do |exercise|
        data << [training.start_time, exercise.summ] if exercise.exercise_name_voc_id == id
      end
    end

    data.sort_by!{ |h| h.first }

    [data, exercises_list, name]
  end
end