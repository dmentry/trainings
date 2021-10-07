class User < ApplicationRecord
  after_create :add_exercises

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :trainings, dependent: :destroy
  has_many :exercises, through: :trainings
  has_many :exercise_name_vocs, dependent: :destroy

  validates :name, presence: true, length: {maximum: 35}

  enum chart_status: { area: 1, linear: 2, column: 3 }

  private

  def add_exercises
    exercises = [
      "Подтягивания",
      "Отжимания",
      "Алмазные отжимания",
      "Выход силой",
      "Скручивания",
      "Бег"
    ]

    exercises.each do |exercise|
      exc = ExerciseNameVoc.new(label: exercise, user_id: self.id)

      exc.save(validate: false)
    end
  end
end