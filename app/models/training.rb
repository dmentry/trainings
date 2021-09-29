class Training < ApplicationRecord
  def self.pics
    {
      "общая": "common.png", "офп": "ofp.png", "выход силой": "powerpullup.png", "подтягивания": "pullup.png",
      "отжимания": "pushup.png", "бег": "run.png", "лыжи": "ski.png", "пресс": "abs.png", "флажок": "flag.png",
      "стойка на руках": "handstand.png"
    }
  end

  belongs_to :user
  has_many :exercises, dependent: :destroy

  validates :label, presence: true, length: { maximum: 45, message: "Не более 45 символов!" }
  validates :start_time, presence: true

  def self.by_month(date)
    Training.all
      .order(start_time: :asc)
        .select{ |training| training.start_time.month == date.month && training.start_time.year == date.year }
  end

  def next
    # a=all_trainings.select{ |training| training[:created_at] > created_at }.first || all_trainings.first
    # a.order(start_time: :asc).first || all_trainings.first
    a=all_trainings.select{ |training| training[:start_time] >= start_time }
    a.sort_by{ |t| t[:created_at] }.first || all_trainings.first
  end

  def prev
    # all_trainings.select{ |training| training[:created_at] < created_at}.last || all_trainings.last
    # a.order(start_time: :asc).last || all_trainings.last
    a=all_trainings.select{ |training| training[:created_at] < created_at }
    a.sort_by{ |t| t[:start_time] }.last || all_trainings.last
  end

  private
  
  def all_trainings
    user.trainings.order(start_time: :asc)
  end
end
