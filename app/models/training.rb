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

  # def next
  #   all_trainings_per_day = all_trainings.select{ |training| training[:start_time] > start_time}.first || all_trainings.first
  # end

  def next(current_training_index)
    next_day_first_training = all_trainings.select{ |training| training[:start_time] > start_time}.first || all_trainings.first

    all_trainings_per_day = Training.where(start_time: next_day_first_training.start_time).to_a

binding.pry
    # all_trainings_per_day.each.with_index do |training, index|
      if all_trainings_per_day.size > 1 && all_trainings_per_day.find_index(Training.find(current_training_index))
        return all_trainings_per_day[all_trainings_per_day.find_index(Training.find(current_training_index)) + 1] if all_trainings_per_day[all_trainings_per_day.find_index(Training.find(current_training_index)) + 1].present?
      else
        return all_trainings_per_day.first
      # end


    end
  end

  def prev
    all_trainings.select{ |training| training[:start_time] < start_time}.last || all_trainings.last
  end

  private
  
  def all_trainings
    user.trainings.order(start_time: :asc)
  end
end
