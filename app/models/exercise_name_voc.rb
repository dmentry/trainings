class ExerciseNameVoc < ApplicationRecord
  has_many :exercises
  belongs_to :user

  validates :label, presence: true, length: {maximum: 255}
  validates :label, uniqueness: true
end
