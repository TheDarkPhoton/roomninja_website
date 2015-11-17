class BookingDay < ActiveRecord::Base
  belongs_to :room

  has_many :booking_times, dependent: :destroy
  accepts_nested_attributes_for :booking_times

  DAYS = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)
  validates_inclusion_of :day, in: DAYS
end
