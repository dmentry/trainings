module ExercisesHelper
  class Summ
    attr_accessor :label, :exercise

    def initialize(params)
      @label = params[:label] || ''

      @exercise = params[:exercise] || 0

      @exercise = @exercise.gsub(" ", "")
    end

    def overall
      if @exercise.split(',').size > 1 && !@label.match?(/лесен|Лесен|бег|лыжи|Бег|Лыжи|ОФП|Офп|офп/)
        overall_summ = 0

        @exercise.split(',') do |match|
          temp_summ = self.dash(@label, match)

          overall_summ += temp_summ if temp_summ

          temp_summ = self.multiply(@label, match)

          overall_summ += temp_summ if temp_summ

          temp_summ = self.one_rep(@label, match)

          overall_summ += temp_summ if temp_summ
        end

        return overall_summ
      else
        temp_summ_1 = self.dash(@label, @exercise) || 0

        temp_summ_2 = self.multiply(@label, @exercise) || 0

        temp_summ_3 = self.ladder(@label, @exercise) || 0

        temp_summ_4 = self.running(@label, @exercise) || 0

        temp_summ_5 = self.one_rep(@label, @exercise) || 0

        return temp_summ_1 + temp_summ_2 + temp_summ_3 + temp_summ_4 + temp_summ_5
      end
    end

  private
    # тире
    def dash(label, exercise)
      if !label.match?(/лесен|Лесен/) && exercise.match?(/-/)
        summ = 0

        exercise.split('-'){ |sub| summ += sub.to_i }

        summ
      end
    end

    # x
    def multiply(label, exercise)
      if exercise.match?(/[xXхХ]/)
        mult = 1

        exercise.split(/[xXхХ]/){ |sub| mult *= sub.to_i }

        mult = 0 if mult == 1

        mult
      end
    end

    # лесенка
    def ladder(label, exercise)
      if label.match?(/лесен|Лесен/)
        max ** 2
      end
    end

    # бег\лыжи
    def running(label, exercise)
      exercise.match(/\d+[.,]\d+|\d+/).to_s.gsub(",", ".").to_f if label && label.match?(/бег|лыжи|Бег|Лыжи/)
    end

    # один подход
    def one_rep(label, exercise)
      unless label.match?(/лесен|Лесен|бег|лыжи|Бег|Лыжи/)
        exercise.match(/\A\d+\z/).to_s.to_i if exercise.match?(/\A\d+\z/)
      end
    end
  end

  def self.achivs_add(current_user, exercise)
    current_user.money += exercise.summ / 3.0
    current_user.save!

    ex_name_voc = ExerciseNameVoc.find(exercise.exercise_name_voc_id)

    next_level = AchievmentsHelper.exercise_exp_process(ex_name_voc, exercise, current_user)

    change_rank(current_user)

    next_level   
  end

  def self.achivs_edit(current_user, exercise, ex_current_summ)
    current_user.money -= ex_current_summ / 3.0
    current_user.money += exercise.summ / 3.0
    current_user.save!

    exercise_name_voc = ExerciseNameVoc.find(exercise.exercise_name_voc_id)

    exercise_name_voc.exp = exercise_name_voc.exp - ex_current_summ.round + exercise.summ.round
    exercise_name_voc.save!

    next_level_exp = 0
    level = exercise.level

    next_level_exp_before = next_level_exp
    level_before = level

    next_level_exp_before ||= exercise_name_voc.exercises.order(id: :desc).find_by("id < ?", exercise.id).next_level_exp
    
    level_before ||= exercise_name_voc.exercises.order(id: :desc).find_by("id < ?", exercise.id).level

    # Понизить или повысить ранг
    change_rank(current_user)

    if (exercise_name_voc.exp >= next_level_exp_before) && (level == level_before)
      level += 1
      next_level_exp = AchievmentsHelper.c_next_level_exp(exercise_name_voc, exercise, current_user) + exercise_name_voc.exp
      @message = { notice: 'Упражнение изменено успешно. Вы получаете новый уровень. Поздравляем!' }
    elsif (exercise_name_voc.exp >= next_level_exp_before) && (level > level_before)
      next_level_exp = AchievmentsHelper.c_next_level_exp(exercise_name_voc, exercise, current_user) + exercise_name_voc.exp
      @message = { notice: 'Упражнение изменено успешно.' }
    elsif (exercise_name_voc.exp < next_level_exp_before) && (exercise.level > level_before)
      level -= 1
      next_level_exp = next_level_exp_before
      @message = { notice: 'Упражнение изменено успешно. Ваш уровень понижен.' }
    else
     next_level_exp = next_level_exp_before
     @message = { notice: 'Упражнение изменено успешно.' }
    end

    exercise.update_attributes!(next_level_exp: next_level_exp, level: level)

    @message
  end

  def self.achivs_delete(current_user, exercise, ex_current_summ, ex_current_level)
    current_user.money -= ex_current_summ / 3.0
    current_user.save!

    exercise_name_voc = ExerciseNameVoc.find(exercise.exercise_name_voc_id)
    exercise_name_voc.exp = exercise_name_voc.exp - ex_current_summ.to_i
    all_ex = exercise_name_voc.exercises.all.order(id: :desc)
    previous_exercise = all_ex.find_by("id < ?", exercise.id)
    level_in_previous_exercise = previous_exercise.level
    exercise_name_voc.save!

    # Понизить ранг, если он был повышен
    change_rank(current_user)

    ex_current_level > level_in_previous_exercise
  end

  private

  def self.change_rank(current_user)
    overall_exp = 0

    current_user.exercise_name_vocs.each do |exercise_name_voc|
      overall_exp += exercise_name_voc.exp
    end

    current_rank_index = User.rank.index{ |x| x[0] == "#{current_user.rank}" }
    next_rank_index = current_rank_index + 1
    previous_rank_index = current_rank_index - 1
    previous_rank_index = 0 if previous_rank_index < 0 
    last_rank_index = User.rank.index{ |x| x[0] == "#{User.rank.last[0]}" }
    first_rank_index = 0

    if overall_exp >= User.rank[next_rank_index][2] && current_rank_index != last_rank_index && current_user.rank != User.rank[next_rank_index][0]
      current_user.rank = User.rank[next_rank_index][0]
      current_user.money += 600
      current_user.save!
    end
    
    if overall_exp < User.rank[current_rank_index][2] && overall_exp >= User.rank[previous_rank_index][2] && current_rank_index != first_rank_index && current_user.rank != User.rank[previous_rank_index][0]
      current_user.rank = User.rank[previous_rank_index][0]
      current_user.money -= 600
      current_user.save!
    end

    current_user.save!
  end 
end
