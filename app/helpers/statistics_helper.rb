module StatisticsHelper
  # REJECT_EXERCISES = ['Флажок с поддержкой', 'Флажок']
  # REJECT_EXERCISES = "'"+REJECT_EXERCISES.join(", ")+"'"
  REJECT_EXERCISES = "'Флажок с поддержкой', 'Флажок'"

  def self.main_stat_helper(current_user, exercise_name_id, months_quantity, last_training)

    # массив всех уникальных названий упражнений [id, название] пользователя, если одинаковых упражнений > 1
    exercises_list = []

    query = <<-SQL
      SELECT label, exercise_name_vocs.id AS exercise_name_voc_id
      FROM exercises JOIN exercise_name_vocs ON exercise_name_voc_id = exercise_name_vocs.id
      WHERE exercise_name_vocs.user_id = #{current_user.id} 
      GROUP BY label, exercise_name_vocs.id
      HAVING COUNT(exercise_name_voc_id) > 1
      ORDER BY label;
    SQL

    exercises_list = ActiveRecord::Base.connection.execute(query).to_a.flatten
    exercises_list.reject! { |e| REJECT_EXERCISES.include?(e['label']) }

    # Выбор упражнения, показываемого по умолчанию
    id = if exercise_name_id
           current_user.options['exercise_show_in_stat'] = exercise_name_id
           current_user.save!

           exercise_name_id.to_i  
         elsif current_user.options['exercise_show_in_stat']
           current_user.options['exercise_show_in_stat'].to_i
         else
           exercises_list.first['label']
         end

    label = Exercise&.find_by(exercise_name_voc: id)&.exercise_name_voc&.label

    # Вычисление промежутка показа тренировок
    first_training = (last_training - (months_quantity.to_i - 1).months).beginning_of_month
    current_trainings = current_user.trainings.where('start_time >= ? AND start_time <= ?', first_training, last_training)

    query = <<-SQL
      SELECT to_char(trainings.start_time, 'DD.MM.YYYY') AS start_date, exercises.summ
      FROM users 
        JOIN trainings ON users.id = trainings.user_id
          JOIN exercises ON trainings.id = exercises.training_id
            JOIN exercise_name_vocs ON exercise_name_vocs.id = exercises.exercise_name_voc_id
      WHERE users.id = #{ current_user.id }
        AND trainings.start_time >= '"#{ first_training }"'
        AND trainings.start_time <= '"#{ last_training }"'
        AND exercises.exercise_name_voc_id = #{ id }
        AND exercise_name_vocs.label NOT IN (#{ REJECT_EXERCISES })
      ORDER BY trainings.start_time
    SQL

    data = ActiveRecord::Base.connection.execute(query).to_a.flatten

    data_formatted = {}

    data.each { |datum| data_formatted[datum['start_date']] = datum['summ'] }

    { data_formatted: data_formatted, exercises_list: exercises_list, label: label, id: id }
  end

  # Количество проведенных упражнений по названиям
  def self.exercises_by_quantity(current_user)
    query = <<-SQL
      SELECT exercise_name_vocs.label, COUNT(exercises.summ)
      FROM users 
        JOIN trainings ON users.id = trainings.user_id 
          JOIN exercises ON trainings.id = exercises.training_id 
            JOIN exercise_name_vocs ON exercise_name_vocs.id = exercises.exercise_name_voc_id
      WHERE users.id = #{ current_user.id }
      GROUP BY exercise_name_vocs.label
      ORDER BY COUNT(exercises.summ) DESC;
    SQL

    data = ActiveRecord::Base.connection.execute(query).to_a.flatten

    data_formatted = {}

    data.each { |datum| data_formatted[datum['label']] = datum['count'] }

    data_formatted
  end

  # Максимальное количество повторов в каждом упражнении
  def self.max_reps_in_each_exercise(current_user)
    query = <<-SQL
      SELECT exercise_name_vocs.label, MAX(exercises.summ)
      FROM users 
        JOIN trainings ON users.id = trainings.user_id 
          JOIN exercises ON trainings.id = exercises.training_id 
            JOIN exercise_name_vocs ON exercise_name_vocs.id = exercises.exercise_name_voc_id
      WHERE users.id = #{ current_user.id }
        AND exercise_name_vocs.label NOT LIKE 'ОФП%'
        AND exercise_name_vocs.label NOT LIKE 'Офп%'
        AND exercise_name_vocs.label NOT LIKE 'офп%'
      GROUP BY exercise_name_vocs.label
      ORDER BY MAX(exercises.summ) DESC;
    SQL

    data = ActiveRecord::Base.connection.execute(query).to_a.flatten

    data_formatted = {}

    data.each { |datum| data_formatted[datum['label']] = datum['max'] }

    data_formatted    
  end

  # Количество тренировок по месяцам
  def self.tr_by_years_months(current_user, all_trainings_by_user)
    # query = <<-SQL
    #   SELECT extract('year' from trainings.start_time)::int as year,
    #   sum(case when extract('month' from trainings.start_time) = 1 then 1 else 0 end ) as Jan,
    #   sum(case when extract('month' from trainings.start_time) = 2 then 1 else 0 end ) as Feb,
    #   sum(case when extract('month' from trainings.start_time) = 3 then 1 else 0 end ) as Mar,
    #   sum(case when extract('month' from trainings.start_time) = 4 then 1 else 0 end ) as Apr,
    #   sum(case when extract('month' from trainings.start_time) = 5 then 1 else 0 end ) as May,
    #   sum(case when extract('month' from trainings.start_time) = 6 then 1 else 0 end ) as Jun,
    #   sum(case when extract('month' from trainings.start_time) = 7 then 1 else 0 end ) as Jul,
    #   sum(case when extract('month' from trainings.start_time) = 8 then 1 else 0 end ) as Aug,
    #   sum(case when extract('month' from trainings.start_time) = 9 then 1 else 0 end ) as Sep,
    #   sum(case when extract('month' from trainings.start_time) = 10 then 1 else 0 end ) as Oct,
    #   sum(case when extract('month' from trainings.start_time) = 11 then 1 else 0 end ) as Nov,
    #   sum(case when extract('month' from trainings.start_time) = 12 then 1 else 0 end ) as Dec
    #   FROM users JOIN trainings ON users.id = trainings.user_id
    #   GROUP BY year
    #   ORDER BY year
    # SQL

    all_tr_by_month = []

    query = <<-SQL
      SELECT DISTINCT extract('year' from trainings.start_time)::int AS year 
      FROM users 
        JOIN trainings ON users.id = trainings.user_id
      ORDER BY year
    SQL
    tr_years = ActiveRecord::Base.connection.execute(query).to_a.flatten
    tr_years = tr_years.map{|h| h['year']}

    tr_years.size.times do |i|
      12.times do |month|
        date = ("01.#{month + 1}.#{tr_years[i]}").to_date

        break if date > Date.today

        tr_by_month = Training.by_month(date, current_user.id).count
        # next unless tr_by_month >= 1
        all_tr_by_month << [date.strftime("%m.%Y"), tr_by_month]
      end
    end

    all_tr_by_month
  end
end
