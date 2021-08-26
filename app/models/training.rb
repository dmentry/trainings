class Training < ApplicationRecord
  belongs_to :user

  validates :label, presence: true, length: {maximum: 255}
  validates :training_dt, presence: true
end
