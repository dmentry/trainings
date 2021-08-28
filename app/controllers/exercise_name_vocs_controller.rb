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
    # @exercise_name_voc = ExerciseNameVoc.new
  end

  # GET /exercise_name_vocs/1/edit
  def edit
  end

  # POST /exercise_name_vocs
  def create
    @exercise_name_voc = ExerciseNameVoc.new(exercise_name_voc_params)

    respond_to do |format|
      if @exercise_name_voc.save
        format.html { redirect_to exercise_name_vocs_path, notice: "Exercise name voc was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /exercise_name_vocs/1
  def update
    respond_to do |format|
      if @exercise_name_voc.update(exercise_name_voc_params)
        format.html { redirect_to exercise_name_vocs_path, notice: "Exercise name voc was successfully updated." }
        format.json { render :show, status: :ok, location: @exercise_name_voc }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @exercise_name_voc.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /exercise_name_vocs/1
  def destroy
    @exercise_name_voc.destroy
    respond_to do |format|
      format.html { redirect_to exercise_name_vocs_url, notice: "Exercise name voc was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_exercise_name_voc
      @exercise_name_voc = ExerciseNameVoc.find(params[:id])
    end

    def exercise_name_voc_params
      params.require(:exercise_name_voc).permit(:label)
    end
end
