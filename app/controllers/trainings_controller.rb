class TrainingsController < ApplicationController
  before_action :set_training, only: %i[ show edit update destroy ]

  def index
    @trainings = Training.all
  end

  def show
  end

  def new
    @training = Training.new
  end

  def edit
  end

  def create
    @training = Training.new(training_params)

    respond_to do |format|
      if @training.save
        format.html { redirect_to @training, notice: "Training was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @training.update(training_params)
        format.html { redirect_to @training, notice: "Training was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @training.destroy
    respond_to do |format|
      format.html { redirect_to trainings_url, notice: "Training was successfully destroyed." }
    end
  end

  private
    def set_training
      @training = Training.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def training_params
      params.require(:training).permit(:label, :training_dt)
    end
end
class TrainingsController < ApplicationController
  before_action :set_training, only: %i[ show edit update destroy ]

  def index
    @trainings = Training.all
  end

  def show
  end

  def new
    @training = Training.new
  end

  def edit
  end

  def create
    @training = Training.new(training_params)

    respond_to do |format|
      if @training.save
        format.html { redirect_to @training, notice: "Training was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @training.update(training_params)
        format.html { redirect_to @training, notice: "Training was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @training.destroy
    respond_to do |format|
      format.html { redirect_to trainings_url, notice: "Training was successfully destroyed." }
    end
  end

  private
    def set_training
      @training = Training.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def training_params
      params.require(:training).permit(:label, :training_dt)
    end
end
