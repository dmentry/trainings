module AchievmentsHelper
  NUMBER_OF_LAST_EX_FOR_AVRG = 3
  NEXT_LEVEL_EXP_RATIO = 1.39

  def self.create_levels(current_user)
    overall_execises = 0

    current_user.exercise_name_vocs.all.each do |ex_name_voc|
      next unless ex_name_voc.exercises.size > 0

      all_ex = ex_name_voc.exercises.all.order(id: :desc)

      first_ex = ex_name_voc.exercises.all.order(:id).first

      ex_name_voc.exercises.all.order(id: :asc).each do |exercise|
        exercise_exp_process(ex_name_voc, exercise, current_user)
      end
    end
  end

  def self.exercise_exp_process(ex_name_voc, exercise, current_user)
    next_level = false
    all_ex = ex_name_voc.exercises.order(id: :desc)
    first_ex = ex_name_voc.exercises.order(:id).first

    next_level_exp = (first_ex.summ * NEXT_LEVEL_EXP_RATIO * 1.5).round(1).round(half: :up)
    current_level = 20

    if exercise != first_ex
      previous_exercise = all_ex.find_by("id < ?", exercise.id)

      next_level_exp = previous_exercise.next_level_exp

      current_level = previous_exercise.level
    end

    ex_name_voc.exp += exercise.summ.round
    ex_name_voc.save!

    if ex_name_voc.exp >= next_level_exp
      current_level += 1
      next_level = true

      next_level_exp = c_next_level_exp(ex_name_voc, exercise, current_user) + ex_name_voc.exp
    end

    exercise.update!(next_level_exp: next_level_exp, level: current_level)

    next_level
  end

  def self.visual_progress(exercise_name_voc)
    current_ex       = exercise_name_voc[0][:exercise_name_voc].exercises.last
    next_l           = exercise_name_voc[0][:exercise_name_voc].exercises.last.next_level_exp - exercise_name_voc[0][:exercise_name_voc].exp
    progress_current = exercise_name_voc[0][:exercise_name_voc].exp
    progress_max     = exercise_name_voc[0][:exercise_name_voc].exercises.last.next_level_exp

    unless exercise_name_voc[0][:exercise_name_voc].exercises.order(id: :desc).find_by("id < ? AND next_level_exp < ?", current_ex.id, current_ex.next_level_exp)&.next_level_exp
      progress_min = progress_max - 0.1
    else
      progress_min   = exercise_name_voc[0][:exercise_name_voc].exercises.order(id: :desc).find_by("id < ? AND next_level_exp < ?", current_ex.id, current_ex.next_level_exp).next_level_exp
    end
    
    current_position = 100 * (progress_current - progress_min) / (progress_max - progress_min)

    output = {
      next_level:       next_l,
      exercise_label:   exercise_name_voc[0][:exercise_name_voc].label,
      current_level:    exercise_name_voc[0][:exercise_name_voc].exercises.last.level,
      current_progress: progress_current,
      current_position: current_position
    }
  end

  def self.token
    numbers  = ('0'..'9').to_a
    letters1 = ('a'..'z').to_a
    letters2 = ('A'..'Z').to_a
    psw_arr  = (letters1 + numbers + letters2).shuffle!
    psw      = ''

    10.times { psw << psw_arr.shuffle!.sample }

    psw
  end

  private

  def self.c_next_level_exp(ex_name_voc, exercise, current_user)
    average_summ = 0.0

    if ex_name_voc.exercises.count >= NUMBER_OF_LAST_EX_FOR_AVRG

      previous_exercises = ex_name_voc.exercises.order(:id).where("id <= ?", exercise.id).last(NUMBER_OF_LAST_EX_FOR_AVRG)

      previous_exercises.each { |ex| average_summ += ex.summ }
      
      average_summ = (average_summ / NUMBER_OF_LAST_EX_FOR_AVRG)
    else
      average_summ = ex_name_voc.exercises.order(id: :asc).first.summ * 1.5
    end

    # Вычисляю коэффициент уменьшения экспы до следующего уровня для тех упражнений, которых присутствует малое количество
    exs_by_quantity = StatisticsHelper.exercises_by_quantity(current_user)
    max_quantity_ex = exs_by_quantity.values.max
    current_quantity_ex = exs_by_quantity[exercise.exercise_name_voc.label]
    ratio = ((100 - (current_quantity_ex * 100 / max_quantity_ex)) / 3.0) / 100
    ratio = 0.2 if ratio <= 0
    ratio_number = (average_summ ** NEXT_LEVEL_EXP_RATIO) * ratio
    ratio_number = 0 if ratio_number == (average_summ ** NEXT_LEVEL_EXP_RATIO)
    ratio_number = average_summ / 4 if ratio_number > average_summ
    #####################################################################################################################

    # Формула для постоянного подсчета уровней
    # average_summ = (average_summ * 4.3 - ratio_number).round(1).round(half: :up)

    # Формула для начального внесения уровней
    average_summ = (average_summ * 0.3).round(1).round(half: :up)
  end  
end
