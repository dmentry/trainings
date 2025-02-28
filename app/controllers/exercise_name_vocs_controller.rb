class ExerciseNameVocsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_user_exercise_name_voc, only: %i[show edit update destroy]

  def index
    @nav_menu_active_item = 'exercise_name_voc'

    @exercise_name_vocs = current_user.exercise_name_vocs.order(:label)
  end

  def show
    @nav_menu_active_item = 'exercise_name_voc'
  end

  def new
    @nav_menu_active_item = 'exercise_name_voc'

    @exercise_name_voc = current_user.exercise_name_vocs.build
  end

  def edit
    @nav_menu_active_item = 'exercise_name_voc'
  end

  def create
    @exercise_name_voc = current_user.exercise_name_vocs.build(exercise_name_voc_params)

    if @exercise_name_voc.save
      redirect_to exercise_name_vocs_path, notice: "Упражнение было успешно создано."
    else
      render :edit, alert: "Упражнение не было создано."
    end
  end

  def update
    if @exercise_name_voc.update(exercise_name_voc_params)
      redirect_to exercise_name_vocs_path, notice: "Упражнение было успешно изменено."
    else
      render :edit, alert: "Упражнение не было изменено."
    end
  end

  def destroy
    if @exercise_name_voc.destroy!
      message = { notice: 'Упражнение удалено успешно.' }
    else
      message = { alert: 'Упражнение не было удалено.' }
    end

    redirect_to exercise_name_vocs_url, message
  end

  private

  def set_current_user_exercise_name_voc
    @exercise_name_voc = current_user.exercise_name_vocs.find(params[:id])
  end

  def exercise_name_voc_params
    params.require(:exercise_name_voc).permit(:label)
  end
end
