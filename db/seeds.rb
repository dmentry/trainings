User.create!(name: 'Дима', email: '11@11.11', password: '123456', admin: true)

exercises = [
  "Подтягивания",
  "Высокие подтягивания",
  "Подтягивания «4xMax»",
  "Подтягивания «Лесенка»",
  "Подтягивания «Таймфрейм 4»",
  "Подтягивания медленные «4xMax»",
  "Подтягивания медленные «Лесенка»",
  "Подтягивания медленные «Таймфрейм 4»",
  "Выход силой",
  "Отжимания",
  "Отжимания на брусе",
  "Отжимания от низкой перекладины",
  "Отжимания «4xMax»",
  "Отжимания «Лесенка»",
  "Отжимания «Таймфрейм 4»",
  "Алмазные отжимания",
  "Отжимания на левой руке",
  "Флажок",
  "Флажок с поддержкой",
  "Пресс на скамье",
  "Наклоны поясницы на скамье",
  "Поднимание коленей к груди",
  "Стрекоза",
  "Бег",
  "Лыжи",
  "ОФП-6",
  "ОФП-7",
  "ОФП-8",
  "ОФП-9",
  "ОФП-10",
  "ОФП-11",
  "ОФП-12",
  "ОФП-13",
  "ОФП-14",
  "ОФП-15",
  "ОФП-16",
  "ОФП-17",
  "ОФП-18",
  "ОФП-19",
  "ОФП-20"

]

exercises.each do |exercise|
  ExerciseNameVoc.create!(label: exercise, user_id: 1)
end
