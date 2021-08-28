class ExerciseNameVoc < ApplicationRecord
  has_many :exercises

  validates :label, presence: true, length: {maximum: 255}
  validates :label, uniqueness: true
end
