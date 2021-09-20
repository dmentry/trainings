module TrainingsHelper
  class TrainingExport
    def self.download_textfile(current_user)
      @current_user = current_user

      trainings = @current_user.trainings.all.order(:start_time)

      tr = ''
      tr << "\n"

      trainings.find_all do |training|
        tr << training.start_time.strftime("%d.%m.%Y").to_s << "\n"

        tr << training.label << "\n"

        training.exercises.sort.find_all do |exercise|
          tr << exercise.exercise_name_voc.label << " "

          tr << exercise.quantity

          tr << " " << exercise.note if exercise.note.present?
          tr << "\n"
        end
        tr << "\n"
      end
      tr
    end
  end

  # Загрузка массива тренировок в базу
  def self.create_trainings_from_lines(lines, user_id)
    overall_execises = 0
    failed           = 0
    errors           = []
    training_date    = ''
    training_label   = ''
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

      training_label = training_array[1]

      t = Training.create(
        user_id:    user_id,
        label:      training_label,
        start_time: training_date
      )

      unless t.valid?
        failed += 1
        errors << "Тренировка не создана: #{training_date.strftime("%d.%m.%Y")}"
      end

      # Парсинг упражнения
      training_array.each do |exercise|
        next if exercise == training_array[0] # пропускаем дату
        next if exercise == training_array[1] # пропускаем название трени

        exercise_comment = ''

        if exercise.match?(/(Отжимания «Руки вдоль тела»)/)
          exercise_label = 'Отжимания «Руки вдоль тела»'
          exercise.gsub!(/Отжимания «Руки вдоль тела» /, '').strip!
          exercise.scan(/(\s[а-яА-ЯЁёa-zA-Z_\s]+)/)
          exercise_comment = $1.strip! if $1
          exercise.gsub!(/(\s[а-яА-ЯЁёa-zA-Z_\s]+)/, '').strip! if $1
          reps = exercise.strip.gsub(/["\[\]]/, '')
        elsif exercise.match?(/(Отжимания «Таймфрейм 4»)/)
          exercise_label = 'Отжимания «Таймфрейм 4»'
          exercise.gsub!(/Отжимания «Таймфрейм 4» /, '').strip!
          exercise.scan(/(\s[а-яА-ЯЁёa-zA-Z_\s]+)/)
          exercise_comment = $1.strip! if $1 if $1
          exercise.gsub!(/(\s[а-яА-ЯЁёa-zA-Z_\s]+)/, '').strip! if $1
          reps = exercise.strip.gsub(/["\[\]]/, '')
        elsif exercise.match?(/(Отжимания «Лесенка»)/)
          exercise_label = 'Отжимания «Лесенка»'
          exercise.gsub!(/Отжимания «Лесенка» /, '').strip!
          exercise.scan(/(\s[а-яА-ЯЁёa-zA-Z_\s]+)/)
          exercise_comment = $1.strip! if $1
          exercise.gsub!(/(\s[а-яА-ЯЁёa-zA-Z_\s]+)/, '').strip! if $1
          reps = exercise.strip.gsub(/["\[\]]/, '')
        elsif exercise.match?(/(Отжимания «4xMax»)/)
          exercise_label = 'Отжимания «4xMax»'
          exercise.gsub!(/Отжимания «4xMax» /, '').strip!
          exercise.scan(/(\s[а-яА-ЯЁёa-zA-Z_\s]+)/)
          exercise_comment = $1.strip! if $1
          exercise.gsub!(/(\s[а-яА-ЯЁёa-zA-Z_\s]+)/, '').strip! if $1
          reps = exercise.strip.gsub(/["\[\]]/, '')
        elsif exercise.match?(/(Подтягивания медленные «Таймфрейм 4»)/)
          exercise_label = 'Подтягивания медленные «Таймфрейм 4»'
          exercise.gsub!(/Подтягивания медленные «Таймфрейм 4» /, '').strip!
          exercise.scan(/(\s[а-яА-ЯЁёa-zA-Z_\s]+)/)
          exercise_comment = $1.strip! if $1
          exercise.gsub!(/(\s[а-яА-ЯЁёa-zA-Z_\s]+)/, '').strip! if $1
          reps = exercise.strip.gsub(/["\[\]]/, '')
        elsif exercise.match?(/(Подтягивания медленные «Лесенка»)/)
          exercise_label = 'Подтягивания медленные «Лесенка»'
          exercise.gsub!(/Подтягивания медленные «Лесенка» /, '').strip!
          exercise.scan(/(\s[а-яА-ЯЁёa-zA-Z_\s]+)/)
          exercise_comment = $1.strip! if $1
          exercise.gsub!(/(\s[а-яА-ЯЁёa-zA-Z_\s]+)/, '').strip! if $1
          reps = exercise.strip.gsub(/["\[\]]/, '')
        elsif exercise.match?(/(Подтягивания медленные «4xMax»)/)
          exercise_label = 'Подтягивания медленные «4xMax»'
          exercise.gsub!(/Подтягивания медленные «4xMax» /, '').strip!
          exercise.scan(/(\s[а-яА-ЯЁёa-zA-Z_\s]+)/)
          exercise_comment = $1.strip! if $1
          exercise.gsub!(/(\s[а-яА-ЯЁёa-zA-Z_\s]+)/, '').strip! if $1
          reps = exercise.strip.gsub(/["\[\]]/, '')
        elsif exercise.match?(/(Подтягивания «Таймфрейм 4»)/)
          exercise_label = 'Подтягивания «Таймфрейм 4»'
          exercise.gsub!(/Подтягивания «Таймфрейм 4» /, '').strip!
          exercise.scan(/(\s[а-яА-ЯЁёa-zA-Z_\s]+)/)
          exercise_comment = $1.strip! if $1
          exercise.gsub!(/(\s[а-яА-ЯЁёa-zA-Z_\s]+)/, '').strip! if $1
          reps = exercise.strip.gsub(/["\[\]]/, '')      
        elsif exercise.match?(/(Подтягивания «Лесенка»)/)
          exercise_label = 'Подтягивания «Лесенка»'
          exercise.gsub!(/Подтягивания «Лесенка» /, '').strip!
          exercise.scan(/(\s[а-яА-ЯЁёa-zA-Z_\s]+)/)
          exercise_comment = $1.strip! if $1
          exercise.gsub!(/(\s[а-яА-ЯЁёa-zA-Z_\s]+)/, '').strip! if $1
          reps = exercise.strip.gsub(/["\[\]]/, '')
        elsif exercise.match?(/(Подтягивания «4xMax»)/)
          exercise_label = 'Подтягивания «4xMax»'
          exercise.gsub!(/Подтягивания «4xMax» /, '').strip!
          exercise.scan(/(\s[а-яА-ЯЁёa-zA-Z_\s]+)/)
          exercise_comment = $1.strip! if $1
          exercise.gsub!(/(\s[а-яА-ЯЁёa-zA-Z_\s]+)/, '').strip! if $1
          reps = exercise.strip.gsub(/["\[\]]/, '')
        elsif exercise.match?(/^ОФП-\d+/)
          exercise_label = exercise.scan(/^ОФП-\d+/)
          exercise_label = exercise_label.to_s.strip.gsub(/["\[\]]/, '')
          exercise.gsub!(/^ОФП-\d+ /, '')
          exercise.scan(/(\s[а-яА-ЯЁёa-zA-Z_.,\s]+)/)
          exercise_comment = $1.strip! if $1
          exercise.gsub!(/(\s[а-яА-ЯЁёa-zA-Z_.,\s]+)/, '').strip! if $1
          reps = exercise.strip.gsub(/["\[\]]/, '')
        elsif exercise.match?(/^[Ббег]{3}|^[Ллыжи]{4}/)
          exercise_label = exercise.scan(/^[Ббег]{3}|^[Ллыжи]{4}/)
          exercise_label = exercise_label.to_s.strip.gsub(/["\[\]]/, '')
          exercise.gsub!(/^[Ббег]{3}|^[Ллыжи]{4} /, '').strip!
          exercise.scan(/(\s[а-яА-ЯЁёa-zA-Z_\s]+)/)
          exercise_comment = $1.strip! if $1
          exercise.gsub!(/(\s[а-яА-ЯЁёa-zA-Z_\s]+)/, '').strip! if $1
          reps = exercise.strip.gsub(/["\[\]]/, '')
        else
          exercise.scan(/(^[а-яА-ЯЁёa-zA-Z_\s]+)/)
          exercise_label = $1.strip! if $1
          exercise.gsub!(/(^[а-яА-ЯЁёa-zA-Z_\s]+)/, '').strip! if $1
          exercise.scan(/(\s[а-яА-ЯЁёa-zA-Z_\s]+)/)
          exercise_comment = $1.strip! if $1
          exercise.gsub!(/(\s[а-яА-ЯЁёa-zA-Z_\s]+)/, '').strip! if $1
          reps = exercise.strip.gsub(/["\[\]]/, '')
        end

        exercise_name_voc = ExerciseNameVoc.where('label = ? and user_id = ?', exercise_label, user_id)

        if exercise_name_voc.present?
          exercise_name_voc_id = exercise_name_voc.to_a[0][:id]
        else
          failed += 1
          
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
    end

    [overall_execises, failed, errors]
  end
end
