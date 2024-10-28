class TrainingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_user_training, only: %i[show edit update destroy]
  before_action :user_admin?, only: %i[trainings_upload_post]
 
  def index
    @training_highlight = params[:training_highlight].to_i if params[:training_highlight]

    if params[:date] && params[:date] == 'next_month'
      @date = begin
                Date.parse(session[:current_date]) + 1.month
              rescue
                Date.today
              end

      current_user.options['calendar_date'] = @date
      current_user.save!
    elsif params[:date] && params[:date] == 'prev_month'
      @date = begin
                Date.parse(session[:current_date]) - 1.month
              rescue
                Date.today
              end

      current_user.options['calendar_date'] = @date
      current_user.save!
    elsif params[:date] && params[:date] == 'current_month'
      @date = Date.today

      current_user.options['calendar_date'] = @date
      current_user.save!
    elsif current_user.name == 'guest'
      @date = '01.10.2021'.to_date
    elsif params[:date]
      @date = Date.parse(params[:date])
    else
      @date = Date.parse(current_user.options['calendar_date'])
    end

    session[:current_date] = @date

    @trainings_by_month = Training.by_month(@date, current_user.id)

    ###### Собираю тренировки для показа. Текущая дата + 1 месяц до нее + 1 месяц после нее
    dt_before_curr_dt = @date - 1.month
    trainings_by_month_before_curr_dt = Training.by_month(dt_before_curr_dt, current_user.id)
    trainings_by_dt_before_curr_dt = trainings_by_month_before_curr_dt.group_by(&:start_time) if trainings_by_month_before_curr_dt.size > 0

    dt_after_curr_dt = @date + 1.month
    trainings_by_month_after_curr_dt = Training.by_month(dt_after_curr_dt, current_user.id)
    trainings_by_dt_after_curr_dt = trainings_by_month_after_curr_dt.group_by(&:start_time) if trainings_by_month_after_curr_dt.size > 0

    @trainings_by_date = Training.by_month(@date, current_user.id).group_by(&:start_time)

    @trainings_by_date = @trainings_by_date.merge(trainings_by_dt_before_curr_dt) if trainings_by_dt_before_curr_dt
    @trainings_by_date = @trainings_by_date.merge(trainings_by_dt_after_curr_dt) if trainings_by_dt_after_curr_dt
    ######
  end

  def show
  end

  def new
    @training = current_user.trainings.build

    day = params[:day].strip

    new_date = current_user.options['calendar_date'].to_s[0,8] + day

    @new_date = Date.parse(new_date)
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
    export_data = TrainingsHelper.export_trainings(current_user)

    send_data export_data, type: 'text', :disposition => "attachment; filename=Тренировки_#{ current_user.name }_#{ Date.today.strftime("%d.%m.%Y") }.txt"
  end

  def instruction
  end

  def all_trainings
    redirect_to trainings_url, alert: " У вас еще нет тренировок." if current_user.trainings.count <= 1

    sourse = current_user.trainings.all

    if params[:collect_by_name].present?
      sourse = sourse.where(label: params[:collect_by_name])
    end

    if params[:sort_by].present?
      Training.column_names.include?(params[:sort_by]) ? params[:sort_by] : params[:sort_by] = "start_time"
      %w[asc desc].include?(params[:sort_direction]) ? params[:sort_direction] : params[:sort_direction] = "asc"

      sourse = sourse.order(params[:sort_by] + ' ' + params[:sort_direction])
    else
      sourse = sourse.order(start_time: :desc)    
    end

    @trainings = sourse
  end

  def copy_training
    (redirect_to :root, alert: "Для сегодняшней даты тренировка уже существует." and return) if current_user.trainings.where(start_time: Date.today).present?

    @training = current_user.trainings.find(params[:current_training_id])

    @dublicate_training = @training.dup

    @dublicate_training.start_time = Date.today

    @training.exercises.each do |exercise|
      @exercise = @dublicate_training.exercises.build(
                                                      quantity: exercise.quantity, note: exercise.note, training_id: @dublicate_training.id, 
                                                      exercise_name_voc_id: exercise.exercise_name_voc_id, summ: exercise.summ, ordnung: exercise.ordnung
                                                     )
      @exercise.save!
    end

    if @dublicate_training.save
      redirect_to @dublicate_training, notice: "Тренировка успешно дублирована."
    else
      render :new, alert: "Тренировка не дублировалась."
    end
  end

  def trainings_upload_new
  end

  def trainings_upload_post
    user_id = params[:user_id].to_i
    t_file  = params[:trainings_file]

    # читаем содержимое файла в массив
    # http://stackoverflow.com/questions/2521053/how-to-read-a-user-uploaded-file-without-saving-it-to-the-database
    if t_file.respond_to?(:read)
      js_string = t_file.read

      js_string_parsed = JSON.parse(js_string, symbolize_names: true)
    elsif t_file.respond_to?(:path)
      js_string = t_file.read

      js_string_parsed = JSON.parse(js_string, symbolize_names: true)
    else
      # если файл нельзя прочитать, отправляем на экшен new c инфой об ошибках
      redirect_to trainings_upload_new_trainings_path, alert: "Некорректный файл: #{t_file.class.name}, #{t_file.inspect}"

      return false
    end

    start_time = Time.now

    # создаем массив тренировок, считаем неудачные
    @statistics = TrainingsHelper.import_trainings(js_string_parsed, user_id)

    # отправляем на страницу index, если все нормально и выводим статистику о проделаных операциях или на errors_page, если есть ошибки
    text = "Обработано упражнений: #{ @statistics[0] }, ошибок: #{ @statistics[1] }, время #{ Time.at((Time.now - start_time).to_i).utc.strftime '%S.%L сек' }"

    message = { notice: text }

    @warning_message = text

    if @statistics[2].present?       
      render 'errors_page'
    else
      redirect_to trainings_path, message
    end
  end

  def searching
    @q = current_user.trainings.all.ransack(params[:q])

    if params[:q]
      @q.sorts = 'start_time DESC' if @q.sorts.empty?
      @trainings_searched = @q.result.includes(:exercises, :exercise_name_vocs)
    end
  end

  def autocomplete_exercise
    scope = current_user.exercise_name_vocs.quick_search(params[:term]).map{ |exercise| { label: exercise.label, id: exercise.id }}

    respond_with scope.to_json
  end

  private

  def set_current_user_training
    @training = current_user.trainings.where(id: params[:id])&.first || current_user.trainings&.last
  end

  def training_params
    params.require(:training).permit(:label, :start_time, :q, :term)
  end
end
