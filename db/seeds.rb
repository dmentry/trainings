User.create!(name: 'Дима', email: '11@11.11', password: '123456', admin: true)

exercises = [
"Бег",
"Выход силой",
"Выход силой негативный",
"Жим гантелей",
"Лыжи",
"Махи гантелями в стороны",
"Наклоны поясницы на скамье",
"Ноги на 90 гр на турнике",
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
"ОФП-7",
"ОФП-8",
"ОФП-9",
"Отжимания",
"Отжимания '4xMax'",
"Отжимания 'Лесенка'",
"Отжимания 'Таймфрейм 4'",
"Отжимания 1 час",
"Отжимания алмазные",
"Отжимания на брусе",
"Отжимания на брусьях",
"Отжимания на левой руке",
"Отжимания от низкой перекладины",
"Поднимание коленей к груди",
"Подтягивания",
"Подтягивания '4xMax'",
"Подтягивания 'Лесенка'",
"Подтягивания 'Таймфрейм 4'",
"Подтягивания 1 час",
"Подтягивания высокие",
"Подтягивания медленные '4xMax'",
"Подтягивания медленные 'Лесенка'",
"Подтягивания медленные 'Таймфрейм 4'",
"Подтягивания серийные",
"Пресс на скамье",
"Протяжка с гантелями",
"Пуловер лёжа с гантелей",
"Сгибание рук с гантелями",
"Складной нож",
"Стрекоза",
"Флажок",
"Флажок с поддержкой",
"Шраги с гантелями"
]

exercises.each do |exercise|
  ex = ExerciseNameVoc.where(label: exercise, user_id: 1).first

  next if ex

  ExerciseNameVoc.create!(label: exercise, user_id: 1)
end
