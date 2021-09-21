class Training < ApplicationRecord
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
    all_trainings.select{ |training| training[:start_time] > start_time}
      .first || all_trainings.first
  end

  def prev
    all_trainings.select{ |training| training[:start_time] < start_time}
      .last || all_trainings.last
  end

  private

  # def month_trainings
  #   user.trainings
  #     .order(start_time: :asc)
  #       .select{ |training| training.start_time.month == self.start_time.month && training.start_time.year == self.start_time.year }
  # end
  def all_trainings
    user.trainings.order(start_time: :asc)
  end
end
