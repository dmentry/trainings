module AchievmentsHelper
  NUMBER_OF_LAST_EX_FOR_AVRG = 3
  NEXT_LEVEL_EXP_RATIO = 1.45

  def self.create_levels(current_user)
    overall_execises = 0
    log              = ''

    # ex_names_voc = current_user.exercise_name_vocs.all.order(:label)

    current_user.exercise_name_vocs.all.each do |ex_name_voc|
      next unless ex_name_voc.exercises.size > 0
      all_ex = ex_name_voc.exercises.all.order(id: :desc)
      first_ex = ex_name_voc.exercises.all.order(:id).first

      next_level_exp = (first_ex.summ ** NEXT_LEVEL_EXP_RATIO).round(1).round(half: :up) * 5
      current_level = 1

      ex_name_voc.exercises.all.order(id: :asc).each do |exercise|
        overall_execises += 1

log << "ex_name_voc.id: #{ex_name_voc.id}. Упражнение #{overall_execises} - #{exercise.exercise_name_voc.label}" << "\n"

        if exercise != first_ex
          # previous_exercise = ex_name_voc.exercises.all.order(:id).find_by("id < ?", exercise.id)
          # previous_exercise = ex_name_voc.exercises.select{ |ex| ex[:id] < exercise.id}.first
          previous_exercise = all_ex.find_by("id < ?", exercise.id)
          next_level_exp = previous_exercise.next_level_exp
          current_level = previous_exercise.level

log << "previous_exercise.id: #{previous_exercise.id}" << "\n"
log << "exercise.id: #{exercise.id}" << "\n"
        end

        ex_name_voc.exp += exercise.summ

        if ex_name_voc.exp >= next_level_exp
          current_level += 1
          next_level_exp = c_next_level_exp(ex_name_voc, exercise) + ex_name_voc.exp
        end

        ex_name_voc.save!
        exercise.update_attributes!(next_level_exp: next_level_exp, level: current_level)

log << "current_level: #{current_level}" << "\n"
log << "exercise.summ: #{exercise.summ}" << "\n"
log << "ex_name_voc.exp: #{ex_name_voc.exp}" << "\n"
log << "next_level_exp: #{next_level_exp}" << "\n\n"
      end
    end
log
  end

  private

  def self.c_next_level_exp(ex_name_voc, exercise)
    average_summ = 0
    if ex_name_voc.exercises.count >= NUMBER_OF_LAST_EX_FOR_AVRG

      previous_exercises = ex_name_voc.exercises.all.order(:id).where("id <= ?", exercise.id).last(3)

      previous_exercises.each { |ex| average_summ += ex.summ }
      
      average_summ = (average_summ / NUMBER_OF_LAST_EX_FOR_AVRG).round(1).round(half: :up)
    else
      average_summ = ex_name_voc.exercises.order(id: :asc).first.summ * 2
    end
    (average_summ ** NEXT_LEVEL_EXP_RATIO).round(1).round(half: :up)
  end  
end
