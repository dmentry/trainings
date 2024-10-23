module TrainingsHelper
  # Экспорт тренировок в файл
  def self.export_trainings(current_user)
    @current_user = current_user

    trainings = @current_user.trainings.all.order(:start_time)

    trainings_json = []

    trainings.each do |training|
      training_hs = {}

      training_hs[:start_time] = training.start_time
      training_hs[:label]      = training.label
      training_hs[:exercises]  = []

      training.exercises.sort.each do |exercise|
        exercise_hs = {}

        exercise_hs[:label]    = exercise.exercise_name_voc.label
        exercise_hs[:quantity] = exercise.quantity
        exercise_hs[:summ]     = exercise.summ
        exercise_hs[:note]     = exercise.note
        exercise_hs[:ordnung]  = exercise.ordnung

        training_hs[:exercises] << exercise_hs
      end

      trainings_json << training_hs
    end

    trainings_json.to_json
  end

  # Загрузка массива тренировок в базу
  def self.import_trainings(all_trainings, user_id)
    overall_trainings = 0
    failed            = 0
    errors            = []

    all_trainings.each do |training|
      overall_trainings += 1

      training_date  = Date.parse(training[:start_time])
      training_label = training[:label]

      t = Training.new(
        user_id:    user_id,
        label:      training_label,
        start_time: training_date
      )

      if t.valid?
        t.save
      else
        failed += 1
        errors << "Тренировка не создана: #{training_date.strftime("%d.%m.%Y")}"
      end

      training[:exercises].each do |exercise|
        exercise_label    = exercise[:label]
        exercise_quantity = exercise[:quantity]
        exercise_ordnung  = exercise[:ordnung]
        exercise_summ     = exercise[:summ]
        exercise_note     = exercise[:note]

        exercise_name_voc = ExerciseNameVoc.where('label = ? and user_id = ?', exercise_label, user_id)

        if exercise_name_voc.present?
          exercise_name_voc_id = exercise_name_voc.first.id
        else
          exercise_name_voc = ExerciseNameVoc.create(label: exercise_label, user_id: user_id)

          if exercise_name_voc
            exercise_name_voc_id = exercise_name_voc.id
          else
            failed += 1
            
            errors << "Невозможно создать упражнение для: #{ training_date.strftime("%d.%m.%Y")}, #{ exercise_label }"

            next
          end
        end

        e = Exercise.new(
          training_id:          t.id,
          exercise_name_voc_id: exercise_name_voc_id,
          quantity:             exercise_quantity,
          note:                 exercise_note,
          summ:                 exercise_summ,
          ordnung:              exercise_ordnung
        )

        if e.valid?
          e.save
        else
          failed += 1
          errors << "Упражнение не создано: #{training_date.strftime("%d.%m.%Y")}, #{exercise_name_voc_id}, #{ exercise_quantity }"
        end
      end
    end

    [overall_trainings, failed, errors]
  end
end
