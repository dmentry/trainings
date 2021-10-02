module AchievmentsHelper
  NUMBER_OF_LAST_EX_FOR_AVRG = 3
  NEXT_LEVEL_EXP_RATIO = 1.15

  def self.create_levels(current_user)
    overall_execises = 0
    log              = ''

    current_user.exercise_name_vocs.all.each do |ex_name_voc|
      next unless ex_name_voc.exercises.size > 0

      all_ex = ex_name_voc.exercises.all.order(id: :desc)

      first_ex = ex_name_voc.exercises.all.order(:id).first

      # next_level_exp = (first_ex.summ * NEXT_LEVEL_EXP_RATIO * 1.5).round(1).round(half: :up)
      # current_level = 1

      ex_name_voc.exercises.all.order(id: :asc).each do |exercise|
        exercise_exp_process(ex_name_voc, exercise, current_user)
      #   if exercise != first_ex
      #     previous_exercise = all_ex.find_by("id < ?", exercise.id)

      #     next_level_exp = previous_exercise.next_level_exp

      #     current_level = previous_exercise.level
      #   end

      #   ex_name_voc.exp += exercise.summ.round

      #   if ex_name_voc.exp >= next_level_exp
      #     current_level += 1

      #     next_level_exp = c_next_level_exp(ex_name_voc, exercise, current_user) + ex_name_voc.exp
      #   end

      #   ex_name_voc.save!
      #   exercise.update_attributes!(next_level_exp: next_level_exp, level: current_level)
      end
    end

    # log
  end

    def self.exercise_exp_process(ex_name_voc, exercise, current_user)
      next_level = false
      all_ex = ex_name_voc.exercises.order(id: :desc)
      first_ex = ex_name_voc.exercises.order(:id).first

      next_level_exp = (first_ex.summ * NEXT_LEVEL_EXP_RATIO * 1.5).round(1).round(half: :up)
      current_level = 1

      if exercise != first_ex
        previous_exercise = all_ex.find_by("id < ?", exercise.id)

        next_level_exp = previous_exercise.next_level_exp

        current_level = previous_exercise.level
      end

      ex_name_voc.exp += exercise.summ.round

      if ex_name_voc.exp >= next_level_exp
        current_level += 1
        next_level = true

        next_level_exp = c_next_level_exp(ex_name_voc, exercise, current_user) + ex_name_voc.exp
      end

      ex_name_voc.save!
      exercise.update_attributes!(next_level_exp: next_level_exp, level: current_level)

      next_level
    end

  private

  def self.c_next_level_exp(ex_name_voc, exercise, current_user)
    average_summ = 0.0

    if ex_name_voc.exercises.count >= NUMBER_OF_LAST_EX_FOR_AVRG

      previous_exercises = ex_name_voc.exercises.order(:id).where("id <= ?", exercise.id).last(3)

      previous_exercises.each { |ex| average_summ += ex.summ }
      
      average_summ = (average_summ / NUMBER_OF_LAST_EX_FOR_AVRG)

    else
      average_summ = ex_name_voc.exercises.order(id: :asc).first.summ * 1.5
    end

    # Вычисляю коэффициент уменьшения экспы до следующего уровня для тех упражений, которых присутствует малое количество
    exs_by_quantity = StatisticsHelper.exercises_by_quantity(current_user)
    max_quantity_ex = exs_by_quantity.values.max
    current_quantity_ex = exs_by_quantity[exercise.exercise_name_voc.label]
    ratio = ((100 - (current_quantity_ex * 100 / max_quantity_ex)) / 3.0) / 100
    ratio = 0.2 if ratio <= 0
    ratio_number = (average_summ ** NEXT_LEVEL_EXP_RATIO) * ratio
    ratio_number = 0 if ratio_number == (average_summ ** NEXT_LEVEL_EXP_RATIO)
    ###############################################################################################################

    average_summ = ((average_summ ** NEXT_LEVEL_EXP_RATIO) - ratio_number).round(1).round(half: :up)
  end  
end
