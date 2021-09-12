class Training < ApplicationRecord
  belongs_to :user
  has_many :exercises, dependent: :destroy

  validates :label, presence: true, length: {maximum: 255}
  validates :start_time, presence: true

  def self.by_month(date)
    Training.all
      .order(start_time: :asc)
        .select{ |training| training.start_time.month == date.month && training.start_time.year == date.year }
  end

  def next
    month_trainings.select{ |training| training[:id].to_i > id}
      .first || month_trainings.first
  end

  def prev
    month_trainings.select{ |training| training[:id].to_i < id}
      .last || month_trainings.last
  end

  private

  def month_trainings
    user.trainings
      .order(start_time: :asc)
        .select{ |training| training.start_time.month == self.start_time.month && training.start_time.year == self.start_time.year }
  end
end
