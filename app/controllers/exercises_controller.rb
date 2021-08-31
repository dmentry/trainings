class ExercisesController < ApplicationController
  before_action :set_training, only: [:create, :destroy, :update, :edit]
  before_action :set_exercise, only: [:destroy, :edit, :update]

  # POST /exercises
  def create
    @exercise = @training.exercises.build(exercise_params)

    if @exercise.save
      count_summ

      redirect_to @training, notice: "Exercise was successfully created."
    else
      # Если ошибки — рендерим здесь же шаблон тренировки (своих шаблонов у упражнения нет)
      render 'trainings/show', alert: 'Упражнение добавить не удалось!'
    end
  end

  def edit
  end

  def update
    if @exercise.update(exercise_params)
      count_summ

      message = {notice: 'Упражнение изменено успешно'}
    else
      message = {alert: 'Упражнение не было изменено'}
    end

    redirect_to @training, message
  end

  # DELETE /exercises/1
  def destroy
    if @exercise.destroy!
      message = {notice: 'Упражнение удалено успешно'}
    else
      message = {alert: 'Упражнение не было удалено'}
    end

    redirect_to @training, message
  end

  private

  def count_summ
    options={ exercise: @exercise.quantity, label: @exercise.exercise_name_voc.label }

    @exercise.summ = ExercisesHelper::Summ.new(options).overall

    @exercise.save!
  end
  
  def set_training
    @training = Training.find(params[:training_id])
  end

  def set_exercise
    @exercise = @training.exercises.find(params[:id])
  end

  def exercise_params
    params.require(:exercise).permit(:quantity, :note, :exercise_name_voc_id, :label, :summ)
  end
end
