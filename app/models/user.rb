class User < ApplicationRecord
  after_create :add_exercises
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :trainings, dependent: :destroy
  has_many :exercises, through: :trainings
  has_many :exercise_name_vocs, dependent: :destroy

  validates :name, presence: true, length: {maximum: 35}
  # validates :email, presence: true, length: {maximum: 255}
  # validates :email, uniqueness: true
  # validates :email, format: /\A[a-zA-Z0-9\-_.]+@[a-zA-Z0-9\-_.]+\z/

  enum chart_status: { area: 1, stepline: 2, linear: 3, column: 4 }


  private

  def add_exercises
    exercises = [
      "Подтягивания",
      "Отжимания",
      "Алмазные отжимания",
      "Выход силой",
      "Скручивания",
      "Бег",
      "\"Лесенка\""
    ]

    exercises.each do |exercise|
      exc = ExerciseNameVoc.new(label: exercise, user_id: self.id)

      exc.save(validate: false)
    end
  end
end