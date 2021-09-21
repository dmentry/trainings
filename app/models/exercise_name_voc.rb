class ExerciseNameVoc < ApplicationRecord
  has_many :exercises, dependent: :destroy
  belongs_to :user

  validates :label, presence: true, length: { maximum: 45, message: "Не более 45 символов!" }
  validates :label, uniqueness: { case_sensitive: false, message: "Такое название упражнения уже есть!" }
end
