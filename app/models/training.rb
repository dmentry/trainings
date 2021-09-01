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
end
