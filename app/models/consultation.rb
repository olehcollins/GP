class Consultation < ApplicationRecord
  validates :price_per_hour, numericality: { message: 'must be a number'}
  validates :location, presence: true
  validates :speciality, presence: true
  validates :experience, numericality: { only_integer: true}
  validates :doctor, presence: true
  validates :price_per_hour, presence: true

  has_many :appointments
  belongs_to :user

  has_many_attached :photos
end
