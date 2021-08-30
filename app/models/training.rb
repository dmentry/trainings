class Training < ApplicationRecord
  belongs_to :user
  has_many :exercises

  validates :label, presence: true, length: {maximum: 255}
  validates :start_time, presence: true

  def self.by_month(date)
    trainings_by_month = []
    Training.all.each do |training|
      if training.start_time.month == date.month && training.start_time.year == date.year
        trainings_by_month << training
      end
    end
    trainings_by_month
  end
end
