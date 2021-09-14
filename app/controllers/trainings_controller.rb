class TrainingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_user_training, only: %i[show edit update destroy]
  before_action :user_admin?, only: %i[trainings_upload_post]
 
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

  def all_trainings
    @trainings = current_user.trainings.all.group_by(&:start_time)
  end

  def trainings_upload_new
  end

  def trainings_upload_post
    user_id = params[:user_id].to_i
    t_file = params[:trainings_file]

    # читаем содержимое файла в массив
    # http://stackoverflow.com/questions/2521053/how-to-read-a-user-uploaded-file-without-saving-it-to-the-database
    if t_file.respond_to?(:readlines)
      file_lines = t_file.readlines
    elsif t_file.respond_to?(:path)
      file_lines = File.readlines(t_file.path)
    else
      # если файл нельзя прочитать, отправляем на экшен new c инфой об ошибках
      redirect_to trainings_upload_new_trainings_path, alert: "Bad file_data: #{t_file.class.name}, #{t_file.inspect}"

      return false
    end

    file_lines = file_lines.join

    start_time = Time.now
    # создаем массив тренировок, считаем неудачные
    @statistics = TrainingsHelper.create_trainings_from_lines(file_lines, user_id)

    # отправляем на страницу index, если все нормально и выводим статистику о проделаных операциях или на errors_page, если есть ошибки
    text = "Обработано упражнений: #{@statistics[0]}, создано упражнений: #{@statistics[0] - @statistics[1]}, время #{Time.at((Time.now - start_time).to_i).utc.strftime '%S.%L сек'}"
    message = { notice: text }
    @warning_message = text

    if @statistics[2].present?       
      render 'errors_page'
    else
      redirect_to trainings_path, message
    end
  end

  private

  def set_current_user_training
    @training = current_user.trainings.find(params[:id])
  end

  def training_params
    params.require(:training).permit(:label, :start_time)
  end

  def user_admin?
    redirect_to trainings_path, alert: "Вам сюда не надо!" unless current_user.admin
  end
end
