class StatisticsController < ApplicationController
  before_action :authenticate_user!
  before_action :user_chart_status, only: :main_stat

  def main_stat
    if current_user.exercises.count <= 1 && current_user.trainings.count <= 1
      redirect_to trainings_url, alert: "У вас еще недостаточно данных для статистики."
    else
      # first_date = Training.where(user_id: current_user).first.start_time
      # last_date = Training.where(user_id: current_user).last.start_time
      first_training = current_user.trainings.first.start_time
      last_training = current_user.trainings.last.start_time.end_of_month
      @max_months_quantity = (last_training.year * 12 + last_training.month) - (first_training.year * 12 + first_training.month)

      stats_output = StatisticsHelper.main_stat_helper(current_user, params[:exercise_name_id], params[:months_quantity] ||= @max_months_quantity, last_training)

      @data = stats_output[0]

      @exercises_list = stats_output[1]

      @name = stats_output[2]

      @id = stats_output[3]

      respond_to do |format|
        format.js { render layout: false }
        format.html { render 'main_stat' }
      end
    end
  end

  ##################################### переменные для текстовой статистики
  def secondary_stat
    if current_user.exercises.count <= 1 && current_user.trainings.count <= 1
      redirect_to trainings_url, alert: "У вас еще недостаточно данных для статистики."
    else
      @all_trainings_by_user ||= current_user.trainings.all
      
      # все тренировки по годам и месяцам
      @all_tr_by_month = []
      tr_years = @all_trainings_by_user.map{ |training| training.start_time.year }.uniq
      tr_years.size.times do |i|
        tr_summ_by_year = 0
        12.times do |month|
          date = Date.parse("01.#{month + 1}.#{tr_years[i]}")
          break if date > Date.today
          tr_by_month = @all_trainings_by_user.by_month(date).count
          # next unless tr_by_month >= 1
          tr_summ_by_year += tr_by_month
          @all_tr_by_month << [date, tr_by_month]
        end
      end
      @all_tr_by_month = @all_tr_by_month.sort_by{ |h| h.first }

      # Количество проведенных упражнений по названиям
      ex_by_label = StatisticsHelper.exercises_by_quantity(current_user)
      @tr_by_label_chart = []
      ex_by_label.each{ |value| @tr_by_label_chart << value }
      @tr_by_label_chart = @tr_by_label_chart.sort_by{ |h| h.second }.reverse!

      # максимальная сумма в каждом упражнении
      @exercises_max_results = Hash.new
        current_user.exercises.all.each do |ex|
          next if ex.exercise_name_voc.label.match?(/ОФП|Офп|офп/)
          @exercises_max_results[ex.exercise_name_voc.label] ||= 0
          @exercises_max_results[ex.exercise_name_voc.label] = ex.summ if ex.summ > @exercises_max_results[ex.exercise_name_voc.label]
      end
      @exercises_max_results = @exercises_max_results.sort_by{ |h| h.second }.reverse!
    end
  end

  private

  def user_chart_status
    @chart_types = User.chart_statuses

    if params[:chart_name_id].to_i <= 0
      @chart_id = User.chart_statuses[current_user.options['chart_status']]
    else
      @chart_id = params[:chart_name_id].to_i

      current_user.options['chart_status'] = User.chart_statuses.key(@chart_id)
      current_user.save!
    end
  end
end
