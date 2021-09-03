class StatisticsController < ApplicationController
  def stat
    @charts = [[1, 'Area'], [2, 'Stepline'], [3, 'Linear'], [4, 'Column']]

    (redirect_to trainings_url, alert: "У вас еще нет данных для статистики.") if Training.count <= 1

    if params[:chart_name_id].to_i <= 0
      @chart_id = 1
    else
      @chart_id = params[:chart_name_id].to_i
    end
    
    @chart_id

    @list = ExerciseNameVoc.all.pluck(:id, :label)

    @data = []

    if params[:exercise_name_id].to_i <= 0
      id = 1
    else
      id = params[:exercise_name_id].to_i
    end

    @name = Exercise&.find_by(exercise_name_voc: id)&.exercise_name_voc&.label

    Training.all.each do |training|
      training.exercises.each do |exercise|
        if exercise.exercise_name_voc_id == id
          @data << [training.start_time, exercise.summ]
        end
      end
    end

    @data = @data.sort
  end
end
