class BookingTime < ActiveRecord::Base
  belongs_to :booking_day

  validates :begin, presence: true
  validates :end, presence: true
end
