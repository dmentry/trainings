class Training < ApplicationRecord
  def self.pics
    {
      "общая": "common.png", "офп": "ofp.png", "выход силой": "powerpullup.png", "подтягивания": "pullup.png",
      "отжимания": "pushup.png", "бег": "run.png", "лыжи": "ski.png", "пресс": "abs.png", "флажок": "flag.png",
      "стойка на руках": "handstand.png", "брусья": "pushup2.png", "гантели": "dumbbell.png"
    }
  end

  belongs_to :user
  has_many :exercises, dependent: :destroy
  has_many :exercise_name_vocs, through: :exercises

  validates :label, presence: true, length: { maximum: 45, message: "Не более 45 символов!" }
  # validates :start_time, presence: true
  validates :start_time, uniqueness: { scope: [:start_time, :user_id], message: "Только одна тренировка в день может быть создана!" }

  def self.by_month(date, current_user_id)
    query = <<-SQL
      SELECT trainings.id, trainings.label, trainings.start_time, trainings.user_id 
      FROM users 
        JOIN trainings ON users.id = trainings.user_id 
      WHERE users.id = #{current_user_id} 
        AND extract('year' from trainings.start_time)::int = #{date.year} 
        AND extract('month' from trainings.start_time)::int = #{date.month} 
      ORDER BY trainings.start_time
    SQL

    Training.find_by_sql(query)
  end

  def next
    all_trainings.select{ |training| training[:start_time] > start_time}.first || all_trainings.first
  end

  def prev
    all_trainings.select{ |training| training[:start_time] < start_time}.last || all_trainings.last
  end

  private
  
  def all_trainings
    user.trainings.order(start_time: :asc)
  end
end
