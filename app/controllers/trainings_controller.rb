class TrainingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_user_training, only: %i[show edit update destroy]
 
  def index
    @trainings = current_user.trainings.all

    @trainings_by_date = @trainings.group_by(&:start_time)

    @date = params[:date] ? Date.parse(params[:date]) : Date.today

    @trainings_by_month = @trainings.by_month(@date)
  end

  def show
  end

  def new
    @training = current_user.trainings.build
  end

  def edit
  end

  def create
    @training = current_user.trainings.build(training_params)
    
    if @training.save
      redirect_to @training, notice: "Тренировка успешно создана."
    else
      render :new, alert: "Тренировка не создалась."
    end
  end

  def update
    if @training.update(training_params)
      redirect_to @training, notice: "Тренировка успешно отредактирована."
    else
      render :edit, alert: "Тренировка не отредактирована."
    end
  end

  def destroy
    if @training.destroy!
      message = { notice: 'Тренировка удалена успешно.' }
    else
      message = { alert: 'Тренировка не была удалена.' }
    end

    redirect_to trainings_url, message
  end

  def download_textfile
    export_data = TrainingsHelper::TrainingExport.download_textfile(current_user)

    send_data export_data,:type => 'text',:disposition => "attachment; filename=Тренировки_#{ Date.today.strftime("%d.%m.%Y") }.txt"
  end

  def instruction
  end

  private

  def set_current_user_training
    @training = current_user.trainings.find(params[:id])
  end

  def training_params
    params.require(:training).permit(:label, :start_time)
  end
end
