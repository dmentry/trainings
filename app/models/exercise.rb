class Exercise < ApplicationRecord
  belongs_to :training
  belongs_to :exercise_name_voc

  validates :training, presence: true
  validates :exercise_name_voc, presence: true

  attr_accessor :find_exercise
end
