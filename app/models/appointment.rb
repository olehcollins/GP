class Appointment < ApplicationRecord
  validates :consultation_id, presence: true
  validates :user_id, presence: true
  validates :date, presence: true, uniqueness: true
  validates :request, presence: true
  validates :doctor, presence: true
  validates :patient, presence: true
  validates :location, presence: true

  belongs_to :consultation
  # doctor
  has_one :user, through: :consultation
end
