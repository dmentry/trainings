# Дневник тренировок

Надоело записывать свои тренировки в текстовом файле. Их уже скопилось много за предыдущие года. Все из-за того, что не смог найти удобное приложение-дневник для ведения тренировок. Перепробовал их множество, но подходящей мне полностиью так и не нашел. Поэтому решил написать сам.

## Сделано:
* Написал парсер и сумматор количества повторов/подходов/бега/лыж
* Различная статистика с графиками
* Приложение многопользовательское
* Экспорт в текстовый файл своих тренировок
* Импорт своих тренировок в базу из текстового файла
* Дублирование существующей тренировки (чтобы не создавать новую с нуля)
* Отображение основных тренировок в календаре в виде иконок
* Запоминает месяц календаря основного экрана
* Запоминает вид отображения графиков и упражнение
* Выбор упражнений в статистике с помощью выпадающего списка
* Модальные окна для создания\редактирования упражнений
* Изменение очередности упражнений в тренировке
* Рефакторинг кода. Увеличилась скорость загрузки главной страницы и страниц статистики
* Поиск по упражнениям, тренировкам и заметкам

## В планах:
* Пагинация
* Таблица достижениий пользователей
* Загрузка аватарки в профиле
* Выбор дня на календаре с помощью js

## Gems:
* Devise
* Apexcharts

## Главный экран:
![Application screenshot](https://github.com/dmentry/trainings/blob/master/screen_fitcalendar.png)

## Попробовать:
https://fitc.herokuapp.com
* email: guest@guest.com
* password: guest1
