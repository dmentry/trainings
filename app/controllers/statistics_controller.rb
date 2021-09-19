class StatisticsController < ApplicationController
  before_action :authenticate_user!

  def stat
    @chart_types = User.chart_statuses
    
    if params[:chart_name_id].to_i <= 0
      @chart_id = User.chart_statuses[current_user.chart_status]
    else
      @chart_id = params[:chart_name_id].to_i

      current_user.update(chart_status: User.chart_statuses.key(@chart_id))
    end

    if current_user.exercises.count <= 1 && current_user.trainings.count <= 1
      redirect_to trainings_url, alert: "У вас еще недостаточно данных для статистики."
    else
      @exercises_list = []

      uniq_exercises = current_user.exercises.all.map do |exercise| 
        exercise.exercise_name_voc.label if current_user.exercises.where(exercise_name_voc_id: exercise.exercise_name_voc_id).count > 1
      end

      uniq_exercises.compact!.uniq!

      ExerciseNameVoc.all.where(user_id: current_user.id).each do |exercise|
        @exercises_list << [exercise.id, exercise.label] if uniq_exercises&.include?(exercise.label)
      end

      @data = []

      if params[:exercise_name_id].to_i <= 0
        id = current_user.exercises.first.exercise_name_voc_id
      else
        id = params[:exercise_name_id].to_i
      end

      @name = Exercise&.find_by(exercise_name_voc: id)&.exercise_name_voc&.label

      current_user.trainings.all.each do |training|
        training.exercises.each do |exercise|
          if exercise.exercise_name_voc_id == id
            @data << [training.start_time, exercise.summ]
          end
        end
      end

      @data = @data.sort_by{ |h| h.first }

      ##################################### переменные для текстовой статистики

      # все тренировки по годам и месяцам
      @all_tr_by_month = []
      tr_years = current_user.trainings.map{ |training| training.start_time.year }.uniq
      (tr_years.size).times do |i|
        tr_summ_by_year = 0
        12.times do |month|
          date = Date.parse("01.#{month + 1}.#{tr_years[i]}")
          break if date > Date.today
          tr_by_month = current_user.trainings.by_month(date).count
          # next unless tr_by_month >= 1
          tr_summ_by_year += tr_by_month
          @all_tr_by_month << [date, tr_by_month]
        end
      end
      @all_tr_by_month = @all_tr_by_month.sort_by{ |h| h.first }

      # все тренировки по названиям
      @tr_by_label = Hash.new
      current_user.trainings.each do |training|
        @tr_by_label[training.label] ||= 0
        @tr_by_label[training.label] += 1
      end
      @tr_by_label_chart = []
      @tr_by_label.each{ |value| @tr_by_label_chart << value }
      @tr_by_label_chart = @tr_by_label_chart.sort_by{ |h| h.second }.reverse!

      # максимальная сумма в каждом упражнении
      @exercises_max_results = Hash.new
        current_user.exercises.all.each do |ex|
          next if ex.exercise_name_voc.label.match?(/ОФП|Офп|офп/)
          @exercises_max_results[ex.exercise_name_voc.label] ||= 0
          @exercises_max_results[ex.exercise_name_voc.label] = ex.summ if ex.summ > @exercises_max_results[ex.exercise_name_voc.label]
      end
      @exercises_max_results = @exercises_max_results.sort_by{ |h| h.second }.reverse!

      # все тренировки
      @trainings = current_user.trainings.all.order(start_time: :desc)
    end
  end
end
