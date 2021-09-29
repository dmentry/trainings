module AchievmentsHelper
  NUMBER_OF_LAST_EX_FOR_AVRG = 3
  NEXT_LEVEL_EXP_RATIO = 3.18

  def self.create_levels(current_user)
    overall_execises = 0
    log              = []

    # ex_names_voc = current_user.exercise_name_vocs.all.order(:label)

    current_user.exercise_name_vocs.all.each do |ex_name_voc|
      next_level_exp = 6
      current_level = 1

      ex_name_voc.exercises.all.order(id: :asc).each do |exercise|
        overall_execises += 1

        if exercise != ex_name_voc.exercises.all.order(:id).first
          # previous_exercise = ex_name_voc.exercises.all.order(:id).find_by("id < ?", exercise.id)
          # previous_exercise = ex_name_voc.exercises.select{ |ex| ex[:id] < exercise.id}.first
          previous_exercise = ex_name_voc.exercises.all.order(id: :desc).find_by("id < ?", exercise.id)
          next_level_exp = previous_exercise.next_level_exp
          current_level = previous_exercise.level
log << "ex_name_voc.id: #{ex_name_voc.id}. Упражнение #{overall_execises} - #{exercise.exercise_name_voc.label}\n"
log << "exercise.id: #{exercise.id}\n"
log << "previous_exercise.id: #{previous_exercise.id}\n"
        end

        ex_name_voc.exp += exercise.summ

        if ex_name_voc.exp >= next_level_exp
          current_level += 1
          next_level_exp = m_next_level_exp(ex_name_voc) + ex_name_voc.exp
        end

        ex_name_voc.save!
        exercise.update_attributes!(next_level_exp: next_level_exp, level: current_level)
log << "exercise.summ: #{exercise.summ}\n"
log << "ex_name_voc.exp: #{ex_name_voc.exp}\n"
log << "current_level: #{current_level}\n"
log << "next_level_exp: #{next_level_exp}\n\n"
      end
    end
log
  end

  private

  def self.m_next_level_exp(ex_name_voc)
    next_level_exp = 0
    if ex_name_voc.exercises.count >= 3
      ex_name_voc.exercises.order(id: :asc).last(3).each { |ex| next_level_exp += ex.summ }
    else
      next_level_exp = 9
    end
    ((next_level_exp / NUMBER_OF_LAST_EX_FOR_AVRG)  * NEXT_LEVEL_EXP_RATIO).round(1).round(half: :up)
  end  
end
