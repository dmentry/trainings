class StatisticsController < ApplicationController
  before_action :authenticate_user!
  before_action :user_chart_status, only: :main_stat

  def main_stat
    redirect_to trainings_url, alert: "У вас еще недостаточно данных для статистики." if current_user.exercises.count <= 1 && current_user.trainings.count <= 1

    first_training = current_user.trainings.first.start_time
    last_training = current_user.trainings.last.start_time.end_of_month

    @max_months_quantity = (last_training.year * 12 + last_training.month) - (first_training.year * 12 + first_training.month)

    stats_output = StatisticsHelper.main_stat_helper(current_user, params[:exercise_name_id], params[:months_quantity] ||= @max_months_quantity, last_training)

    @data = stats_output[:data_formatted]

    @exercises_list = stats_output[:exercises_list]

    @name = stats_output[:name]

    @id = stats_output[:id]

    respond_to do |format|
      format.js { render layout: false }
      format.html { render 'main_stat' }
    end
  end

##################################### переменные для второй статистики
  def secondary_stat
    redirect_to trainings_url, alert: "У вас еще недостаточно данных для статистики." if current_user.exercises.count <= 1 && current_user.trainings.count <= 1

    @all_trainings_by_user ||= current_user.trainings.all

    # Количество тренировок по месяцам
    @all_tr_by_month_formatted = StatisticsHelper.tr_by_years_months(current_user, @all_trainings_by_user)

    # Процент худших месяцев по количеству тренировок по сравнению с текущим
    current_month_trainings_quantity = @all_tr_by_month_formatted.last[1]

    worse_trainings_quantity = 0

    @all_tr_by_month_formatted.each do |training|
      next if training[1] == 0
      worse_trainings_quantity += 1 if current_month_trainings_quantity > training[1]
    end

    @worse_trainings_ration = worse_trainings_quantity * 100 / @all_tr_by_month_formatted.size

    # Количество проведенных упражнений по названиям
    @tr_by_label_chart = StatisticsHelper.exercises_by_quantity(current_user)

    # Максимальное количество повторов в каждом упражнении
    @exercises_max_results = StatisticsHelper.max_reps_in_each_exercise(current_user)
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
