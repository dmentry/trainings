class StatisticsController < ApplicationController
  def stat
    @list=ExerciseNameVoc.all.pluck(:id, :label)

    @data = []

    if params[:exercise_name_id].to_i <= 0
      id = 1
    else
      id = params[:exercise_name_id].to_i
    end

    Training.all.each do |training|
      training.exercises.each do |exercise|
        if exercise.exercise_name_voc_id == id
          @name = exercise.exercise_name_voc.label

          @data << [training.start_time, exercise.summ]
        end
      end
    end

    @data
  end

  def statistic_params
    params.require(:statistic).permit(:exercise_name_id)
  end
end
