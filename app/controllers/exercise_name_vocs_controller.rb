class ExerciseNameVocsController < ApplicationController
  before_action :set_exercise_name_voc, only: %i[ show edit update destroy ]

  # GET /exercise_name_vocs
  def index
    @exercise_name_vocs = ExerciseNameVoc.all
  end

  # GET /exercise_name_vocs/1
  def show
  end

  # GET /exercise_name_vocs/new
  def new
  end

  # GET /exercise_name_vocs/1/edit
  def edit
  end

  # POST /exercise_name_vocs
  def create
    @exercise_name_voc = ExerciseNameVoc.new(exercise_name_voc_params)

    if @exercise_name_voc.save
      redirect_to exercise_name_vocs_path, notice: "Упражнение было успешно создано."
    else
      render :new, alert: "Упражнение не было создано."
    end
  end

  # PATCH/PUT /exercise_name_vocs/1
  def update
    if @exercise_name_voc.update(exercise_name_voc_params)
      redirect_to exercise_name_vocs_path, notice: "Упражнение было успешно изменено."
    else
      render :edit, alert: "Упражнение не было изменено."
    end
  end

  # DELETE /exercise_name_vocs/1
  def destroy
    if @exercise_name_voc.destroy!
      message = { notice: 'Упражнение удалено успешно.' }
    else
      message = { alert: 'Упражнение не было удалено.' }
    end

    redirect_to exercise_name_vocs_url, message
  end

  private

  def set_exercise_name_voc
    @exercise_name_voc = ExerciseNameVoc.find(params[:id])
  end

  def exercise_name_voc_params
    params.require(:exercise_name_voc).permit(:label)
  end
end
