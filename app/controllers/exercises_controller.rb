class ExercisesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_training, only: [:create, :destroy, :update, :edit, :up, :down]
  before_action :set_exercise, only: [:destroy, :edit, :update]

def new
  @training = Training.find(params[:training_id])
  @exercise = @training.exercises.build

  respond_to do |format|
    format.html
    format.js { render layout: false }
  end
end

  def create
    @exercise = @training.exercises.build(exercise_params)

    if @exercise.save

      last_ordnung = @training.exercises.pluck(:ordnung).max + 1
      @exercise.ordnung = last_ordnung
      @exercise.save!

      count_summ

      redirect_to @training, notice: "Упражнение успешно создано."
    else
      # Если ошибки — рендерим здесь же шаблон тренировки (своих шаблонов у упражнения нет)
      render 'trainings/show', alert: "Упражнение добавить не удалось."
    end
  end

  def edit
  end

  def update
    if @exercise.update(exercise_params)
      count_summ

      message = { notice: 'Упражнение изменено успешно.' }
    else
      message = { alert: 'Упражнение не было изменено.' }
    end

    redirect_to @training, message
  end

  def destroy
    if @exercise.destroy!
      message = { notice: 'Упражнение удалено успешно.' }
    else
      message = { alert: 'Упражнение не было удалено.' }
    end

    redirect_to @training, message
  end

  def up
    exercise_to_change = @training.exercises.find(params[:exercise_id])

    if exercise_to_change.ordnung <= @training.exercises.pluck(:ordnung).min
      redirect_to @training
    else
      exercise_before = nil
      exercise_before = @training.exercises&.where(ordnung: exercise_to_change.ordnung - 1).first

      if exercise_before.present?
        exercise_to_change.ordnung = exercise_to_change.ordnung - 1
        exercise_to_change.save!

        exercise_before.ordnung = exercise_before.ordnung + 1
        exercise_before.save!
      end

      respond_to do |format|
        format.js{ render layout: 'trainings/show' }
        format.html{ render 'trainings/show' }
      end
    end
  end

  def down
    exercise_to_change = @training.exercises.find(params[:exercise_id])

    if exercise_to_change.ordnung >= @training.exercises.pluck(:ordnung).max
      redirect_to @training
    else
      exercise_after = nil
      exercise_after = @training.exercises&.where(ordnung: exercise_to_change.ordnung + 1).first

      if exercise_after.present?
        exercise_to_change.ordnung = exercise_to_change.ordnung + 1
        exercise_to_change.save!

        exercise_after.ordnung = exercise_after.ordnung - 1
        exercise_after.save!
      end

      respond_to do |format|
        format.js{ render layout: 'trainings/show' }
        format.html{ render 'trainings/show' }
      end
    end
  end

  private

  def count_summ
    options = { exercise: @exercise.quantity, label: @exercise.exercise_name_voc.label }

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
