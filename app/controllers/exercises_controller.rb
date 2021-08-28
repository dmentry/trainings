class ExercisesController < ApplicationController
  before_action :set_training, only: [:create, :destroy]
  before_action :set_exercise, only: [:destroy]

  # POST /exercises
  def create
    # Создаём объект @new_exercise из @training
    @new_exercise = @training.exercises.build(exercise_params)

      if @new_exercise.save
        redirect_to @training, notice: "Exercise was successfully created."
      else
        # Если ошибки — рендерим здесь же шаблон события (своих шаблонов у коммента нет)
        render 'trainings/show', alert: 'Упражнение добавить не удалось!'
      end

  end

  # DELETE /exercises/1
  def destroy
    
    respond_to do |format|
      format.html { redirect_to exercises_url, notice: "Exercise was successfully destroyed." }
      format.json { head :no_content }

      
      if @exercise.destroy!
        message = {notice: 'Упражнение удалено успешно'}
      else
        message = {alert: I18n.t('controllers.comments.error')}
      end

      redirect_to @training, message
    end
  end

  private
    def set_training
      @training = Training.find(params[:training_id])
    end
    
    def set_exercise
      @exercise = @training.exercises.find(params[:id])
    end

    def exercise_params
      params.require(:exercise).permit(:quantity, :note)
    end
end
