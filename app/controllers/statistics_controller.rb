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

    @exercises_list = []

    uniq_exercises_list = current_user.exercises.all.map{ |exercise| exercise.exercise_name_voc.label }.uniq!

    ExerciseNameVoc.all.where(user_id: current_user.id).each do |exercise|
      @exercises_list << [exercise.id, exercise.label] if uniq_exercises_list.include?(exercise.label)
    end

    @exercises_list << [(@exercises_list.count + 1), 'Все упражнения']

    @data = []

    if params[:exercise_name_id].to_i <= 0
      if current_user.exercises.count <= 1 && current_user.trainings.count <= 1
        redirect_to trainings_url, alert: "У вас еще недостаточно данных для статистики."
      else
        id = current_user.exercises.first.exercise_name_voc_id
      end
    else
      id = params[:exercise_name_id].to_i
    end

    unless id == @exercises_list.count
      @name = Exercise&.find_by(exercise_name_voc: id)&.exercise_name_voc&.label

      current_user.trainings.all.each do |training|
        training.exercises.each do |exercise|
          if exercise.exercise_name_voc_id == id
            @data << [training.start_time, exercise.summ]
          end
        end
      end
    else
      @name = 'Все упражнения'
      
      (@exercises_list.count - 1).times do |i|
        data_temp = []

        current_user.trainings.all.each do |training|
          training.exercises.each do |exercise|
            if exercise.exercise_name_voc.label == @exercises_list[i][1]
              data_temp << [training.start_time, exercise.summ]
            end
          end
        end
        
        data_temp = data_temp.sort

        @data << {name: @exercises_list[i][1], data: data_temp}
      end
    end

    @data
  end
end
