class StatisticsController < ApplicationController
  def stat
    @charts = User.chart_statuses
    
    if params[:chart_name_id].to_i <= 0
      @chart_id = User.chart_statuses[User.first.chart_status]

    else
      @chart_id = params[:chart_name_id].to_i

      User.first.update(chart_status: User.chart_statuses.key(@chart_id))
    end



@list_temp = []
@list = []
    # @list = ExerciseNameVoc.all.pluck(:id, :label)

    Exercise.all.each do |exercise|

      @list_temp << exercise.exercise_name_voc.label

    end

    @list_temp.uniq!

        ExerciseNameVoc.all.each do |exercise|
          @list << [exercise.id, exercise.label] if @list_temp.include?(exercise.label)

# binding.pry
    end

# @list


    @data = []

    if params[:exercise_name_id].to_i <= 0
      if Exercise.count <= 1 && Training.count <= 1
        redirect_to trainings_url, alert: "У вас еще нет данных для статистики."
      else
      id = Exercise.first.exercise_name_voc_id
    end
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
