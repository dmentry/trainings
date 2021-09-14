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
    # Создаем сразу массив тренировок, считаем неудачные
    @statistics = create_trainings_from_lines(file_lines, user_id)

    # отправляем на страницу index, если все нормально и выводим статистику о проделаных операциях или на errors_page, если есть ошибки
    if @statistics.present?
      @warning_message = "Обработано упражнений: #{@statistics[0]}," +
                  " создано упражнений: #{@statistics[0] - @statistics[1]}," +
                  " время #{Time.at((Time.now - start_time).to_i).utc.strftime '%S.%L сек'}"
                  
      render 'errors_page'
    else
    redirect_to trainings_path, notice: "Обработано упражнений: #{@statistics[0]}," +
                  " создано упражнений: #{@statistics[0] - @statistics[1]}," +
                  " время #{Time.at((Time.now - start_time).to_i).utc.strftime '%S.%L сек'}"
    end
  end

  private

  def set_current_user_training
    @training = current_user.trainings.find(params[:id])
  end

  def training_params
    params.require(:training).permit(:label, :start_time)
  end

  # Загрузка массива тренировок в базу
  def create_trainings_from_lines(lines, user_id)
    overall_execises = 0
    failed           = 0
    errors           = []
    training_date    = ''
    exercise_label   = ''
    reps             = ''
    exercise_comment = ''

    # Разбивка по тренировкам
    all_trainings = lines.scan(/^\n((?:\n|.)*?)\n$/)

    # Парсинг каждой тренировки
    all_trainings.each do |training|
      overall_execises += 1

      training_array = training[0].split(/\n/)

      training_date = Date.parse(training_array[0])

      t = Training.create(
        user_id:    user_id,
        label:      training_date.strftime("%d.%m.%Y"),
        start_time: training_date
      )

      unless t.valid?
        failed += 1
        errors << "Тренировка не создана: #{training_date.strftime("%d.%m.%Y")}"
      end

      # puts training_date

      # Парсинг упражнения
      training_array.each do |exercise|
        next if exercise == training_array[0] # пропускаем дату

        exercise_comment = ''

        if exercise.match?(/(Отжимания «Таймфрейм 4»)/)
          exercise_label = exercise.scan(/(Отжимания «Таймфрейм 4»)/).to_s.strip.gsub(/["\[\],]/, '')
          exercise.gsub!(/(Отжимания «Таймфрейм 4»)/, '').strip!
          reps = exercise.scan(/[0-9xXхХ-]+/).to_s.strip.gsub(/["\[\]]/, '')
        elsif exercise.match?(/(Отжимания «Лесенка»)/)
          exercise_label = exercise.scan(/(Отжимания «Лесенка»)/).to_s.strip.gsub(/["\[\],]/, '')
          exercise.gsub!(/(Отжимания «Лесенка»)/, '').strip!
          reps = exercise.scan(/[0-9xXхХ-]+/).to_s.strip.gsub(/["\[\]]/, '')
        elsif exercise.match?(/(Отжимания «4xMax»)/)
          exercise_label = exercise.scan(/(Отжимания «4xMax»)/).to_s.strip.gsub(/["\[\],]/, '')
          exercise.gsub!(/(Отжимания «4xMax»)/, '').strip!
          reps = exercise.scan(/[0-9xXхХ-]+/).to_s.strip.gsub(/["\[\]]/, '')
        elsif exercise.match?(/(Подтягивания медленные «Таймфрейм 4»)/)
          exercise_label = exercise.scan(/(Подтягивания медленные «Таймфрейм 4»)/).to_s.strip.gsub(/["\[\],]/, '')
          exercise.gsub!(/(Подтягивания медленные «Таймфрейм 4»)/, '').strip!
          reps = exercise.scan(/[0-9xXхХ-]+/).to_s.strip.gsub(/["\[\]]/, '')
        elsif exercise.match?(/(Подтягивания медленные «Лесенка»)/)
          exercise_label = exercise.scan(/(Подтягивания медленные «Лесенка»)/).to_s.strip.gsub(/["\[\],]/, '')
          exercise.gsub!(/(Подтягивания медленные «Лесенка»)/, '').strip!
          reps = exercise.scan(/[0-9xXхХ-]+/).to_s.strip.gsub(/["\[\]]/, '')
        elsif exercise.match?(/(Подтягивания медленные «4xMax»)/)
          exercise_label = exercise.scan(/(Подтягивания медленные «4xMax»)/).to_s.strip.gsub(/["\[\],]/, '')
          exercise.gsub!(/(Подтягивания медленные «4xMax»)/, '').strip!
          reps = exercise.scan(/[0-9xXхХ-]+/).to_s.strip.gsub(/["\[\]]/, '')
        elsif exercise.match?(/(Подтягивания «Таймфрейм 4»)/)
          exercise_label = exercise.scan(/(Подтягивания «Таймфрейм 4»)/).to_s.strip.gsub(/["\[\],]/, '')
          exercise.gsub!(/(Подтягивания «Таймфрейм 4»)/, '').strip!
          reps = exercise.scan(/[0-9xXхХ-]+/).to_s.strip.gsub(/["\[\]]/, '')
        elsif exercise.match?(/(Подтягивания «Лесенка»)/)
          exercise_label = exercise.scan(/(Подтягивания «Лесенка»)/).to_s.strip.gsub(/["\[\],]/, '')
          exercise.gsub!(/(Подтягивания «Лесенка»)/, '').strip!
          reps = exercise.scan(/[0-9xXхХ-]+/).to_s.strip.gsub(/["\[\]]/, '')
        elsif exercise.match?(/(Подтягивания «4xMax»)/)
          exercise_label = exercise.scan(/(Подтягивания «4xMax»)/).to_s.strip.gsub(/["\[\],]/, '')
          exercise.gsub!(/(Подтягивания «4xMax»)/, '').strip!
            reps = exercise.scan(/[0-9xXхХ-]+/).to_s.strip.gsub(/["\[\]]/, '')
        elsif exercise.match?(/^[ОФП]{3}|^[ЛФК]{3}/)
          next
        elsif exercise.match?(/^\d+\)/)
          #берем название упражнения
          exercise_label = exercise.scan(/^\d+\)/)
          #готовим строку, преобразовывая ее из массива и убирая ненужные символы
          exercise_label = exercise_label.to_s.strip.gsub(/["\[\]]/, '')
          exercise_label = "ОФП-#{exercise_label}".chomp(')')
          #убираем из строки название упражнения
          exercise.gsub!(/^\d+\)/, '')
          #убираем из строки комментарий
          exercise_comment = exercise.scan(/[а-яА-ЯЁёa-zA-Z_]+$/)
          exercise_comment = exercise_comment.to_s.strip.gsub(/["\[\]]/, '')
          exercise.gsub!(/[а-яА-ЯЁёa-zA-Z_]+$/, '')
          #готовим строку подходов, преобразовывая ее из массива и убирая ненужные символы
          reps = exercise.scan(/[0-9xXхХ-]+/).to_s.strip.gsub(/["\[\]]/, '')
        elsif
          exercise.match?(/^[бегБ]{3}|^[лыжиЛ]{4}/)
          exercise_label = exercise.scan(/^[бегБ]{3}|^[лыжиЛ]{4}/).to_s.strip.gsub(/["\[\]]/, '')
          exercise.gsub!(/^[бегБ]{3}|^[лыжиЛ]{4}/, '').strip!
          reps = exercise
        else
          exercise_label = exercise.scan(/[а-яА-ЯЁёa-zA-Z_]+\b/).to_s.strip.gsub(/["\[\],]/, '')
          exercise.gsub!(/^[а-яА-ЯЁёa-zA-Z0-9_]+\b/, '').strip!
          reps = exercise.scan(/[0-9xXхХ-]+/).to_s.strip.gsub(/["\[\]]/, '')
        end

        # puts "#{exercise_label} #{reps} #{exercise_comment}"

        exercise_name_voc = ExerciseNameVoc.where('label = ? and user_id = ?', exercise_label, user_id)

        if exercise_name_voc.present?
          exercise_name_voc_id = exercise_name_voc.to_a[0][:id]
        else
          failed += 1
          puts exercise_label
          errors << "Не найдено упражнение для: #{training_date.strftime("%d.%m.%Y")}, #{exercise_label}"

          next
        end

        options = { exercise: reps, label: exercise_label }

        summ = ExercisesHelper::Summ.new(options).overall

        e = Exercise.create(
          training_id:          t.id,
          exercise_name_voc_id: exercise_name_voc_id,
          quantity:             reps,
          note:                 exercise_comment,
          summ:                 summ
        )

        unless e.valid?
          failed += 1
          errors << "Упражнение не создано: #{training_date.strftime("%d.%m.%Y")}, #{exercise_name_voc_id}, #{reps}"
        end
      end
      
      # puts
    end

    [overall_execises, failed, errors]
  end
end
