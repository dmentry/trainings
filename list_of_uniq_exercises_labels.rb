# Метод длдя получения списка уникальных названий упражнений.
# Нужен при импорте тренировок пользователя в чистую БД.

def uniq_exercises_labels(lines)
  training_label   = ''
  exercise_label   = ''
  labels=[]
  # Разбивка по тренировкам
  all_trainings = lines.scan(/^\n((?:\n|.)*?)\n$/)

  # Парсинг каждой тренировки
  all_trainings.each do |training|

    training_array = training[0].split(/\n/)

    training_label = training_array[1]

    # Парсинг упражнения
    training_array.each do |exercise|
      next if exercise == training_array[0] # пропускаем дату
      next if exercise == training_array[1] # пропускаем название трени

      exercise_label = exercise.match(/^.+\#{5}/).to_s.gsub(/\#{5}/, '').strip

      labels << exercise_label
    end
  end

  labels.uniq.sort
end

t_file = File.open("trainings_backup.txt")

file_lines = t_file.readlines.join

out=uniq_exercises_labels(file_lines)

out2=[]

out.each { |tr| out2 << "'#{ tr }'" }

out2=out2.join(',').gsub( /'/,  "\"" )

puts out2