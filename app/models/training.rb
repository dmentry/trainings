class Training < ApplicationRecord
  belongs_to :user
  has_many :exercises

  validates :label, presence: true, length: {maximum: 255}
  validates :start_time, presence: true
end
