class BookingTime < ActiveRecord::Base
  belongs_to :booking_day
  belongs_to :user

  validates :begin, presence: true
  validates :end, presence: true
end
