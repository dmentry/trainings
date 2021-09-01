class StatisticsController < ApplicationController
  def index
    @data = []

    Training.all.each do |training|
      training.exercises.each do |exercise|
        @name = exercise.exercise_name_voc.label

        @data << [training.start_time, exercise.summ]
      end
    end
  end

end
