class User < ApplicationRecord
  has_many :trainings, dependent: :destroy

  validates :name, presence: true, length: {maximum: 35}
  validates :email, presence: true, length: {maximum: 255}
  validates :email, uniqueness: true
  validates :email, format: /\A[a-zA-Z0-9\-_.]+@[a-zA-Z0-9\-_.]+\z/

  enum chart_status: { area: 1, stepline: 2, linear: 3, column: 4 }
end
