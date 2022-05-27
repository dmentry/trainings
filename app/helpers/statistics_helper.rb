module StatisticsHelper
  REJECT_EXERCISES = ['Флажок с поддержкой']

  def self.main_stat_helper(current_user, exercise_name_id, months_quantity, last_training)

    # массив всех уникальных упражнений пользователя [id, название], если одинаковых упражнений > 1
    exercises_list = []

    ExerciseNameVoc.where(user_id: current_user.id).each do |exercise|
      exercises_list << [exercise.id, exercise.label] if current_user.exercises.where(exercise_name_voc_id: exercise.id).count > 1
    end

    exercises_list.uniq! { |e| e.second }

    exercises_list.reject! { |e| REJECT_EXERCISES.include?(e.second) }

    exercises_list.sort_by!{ |h| h.second }

    data = []

    # Выбор упражнения, показываемого по умолчанию
    id = 0
    if exercise_name_id
      id = exercise_name_id.to_i

      current_user.options['exercise_show_in_stat'] = exercise_name_id
      current_user.save!      
    elsif current_user.options['exercise_show_in_stat']
      id = current_user.options['exercise_show_in_stat'].to_i
    else
      id = exercises_list.first[0]
    end

    name = Exercise&.find_by(exercise_name_voc: id)&.exercise_name_voc&.label

    # Вычисление промежутка показа тренировок
    # last_training = current_user.trainings.last.start_time.end_of_month
    first_training = (last_training - (months_quantity.to_i - 1).months).beginning_of_month
    current_trainings = current_user.trainings.where('start_time >= ? AND start_time <= ?', first_training, last_training)

    current_trainings.each do |training|
    # current_user.trainings.each do |training|
      training.exercises.each do |exercise|
        data << [training.start_time, exercise.summ] if exercise.exercise_name_voc_id == id && REJECT_EXERCISES.exclude?(exercise.exercise_name_voc.label)
      end
    end

    # data = Exercise.where('exercise_name_voc_id =? AND training_id = ?', id, current_user.training_ids)

    data.to_a.sort_by!{ |h| h.first }

    [data, exercises_list, name, id]
  end

  # Количество проведенных упражнений по названиям
  def self.exercises_by_quantity(current_user)
    ex_by_label = Hash.new
    current_user.exercise_name_vocs.each do |exercise_name_voc|
      exercise_name_voc.exercises.each do |exercise|
        ex_by_label[exercise.exercise_name_voc.label] ||= 0
        ex_by_label[exercise.exercise_name_voc.label] += 1
      end
    end

    ex_by_label
  end
end
