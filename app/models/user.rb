class User < ApplicationRecord
  after_create :add_exercises
  after_create :assign_rank

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

  # def self.rank
  #   [
  #     ['Юнга', 'yunga.png', 0], ['Старший юнга', 'starshiy_yunga.png', 6500], ['Моряк', 'moryak.png', 8600], ['Боцман', 'botsman.png', 11700], 
  #     ['Помощник капитана', 'pomoshnik_kapitana.png', 14000], ['Капитан', 'kapitan.png', 17000], ['Морской волк', 'morskoi_volk.png', 21000], 
  #     ['Гроза морей', 'groza_morei.png', 25000]
  #   ]
  # end

  def self.rank
    [
      ['Юнга', 'yunga.png', 0], ['Старший юнга', 'starshiy_yunga.png', 5650], ['Моряк', 'moryak.png', 5700], ['Боцман', 'botsman.png', 5750], 
      ['Помощник капитана', 'pomoshnik_kapitana.png', 5800], ['Капитан', 'kapitan.png', 5850], ['Морской волк', 'morskoi_volk.png', 5900], 
      ['Гроза морей', 'groza_morei.png', 5950]
    ]
  end

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

  def assign_rank
    self.rank = User.rank[0][0]
    self.save!
  end
end