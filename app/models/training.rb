class Training < ApplicationRecord
  belongs_to :user

  validates :label, presence: true, length: {maximum: 255}
  validates :start_time, presence: true
end
