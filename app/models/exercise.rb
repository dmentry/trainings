class Exercise < ApplicationRecord
  belongs_to :training
  belongs_to :exercise_name_voc

  validates :training, presence: true
  validates :exercise_name_voc, presence: true

  def set_next_level_exp
    (self.summ * 3.15).round(1).round(half: :up)
  end
end
