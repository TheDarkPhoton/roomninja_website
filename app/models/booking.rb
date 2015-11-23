class Booking < ActiveRecord::Base
  require 'numeric'

  attr_accessor :for_hours
  attr_accessor :for_minutes

  belongs_to :room
  belongs_to :user

  validates :begin, presence: true
  validates :end, presence: true
  validate :is_not_overlapping
  validate :booking_length
  validate :booking_datetime
  validate :owner

  DAYS = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)

  STATUSES = %w(Generated Booked Expired Canceled)
  GENERATED = STATUSES[0]
  BOOKED = STATUSES[1]
  EXPIRED = STATUSES[2]
  CANCELED = STATUSES[3]

  validates_inclusion_of :status, in: STATUSES

  def form_name
    "#{self.room.name} booking"
  end

  def day
    begin
      DAYS[self.begin.wday]
    rescue => e
      return nil
    end
  end

  def length
    self.end.to_i - self.begin.to_i
  end

  def self.overlapping(begin_time, end_time)
    where('(? > begin AND ? < end) OR (? > begin AND ? < end) OR (? <= begin AND ? >= end)',
          begin_time,
          begin_time,
          end_time,
          end_time,
          begin_time,
          end_time)
  end

  def self.booking_allowance
    5.hours
  end

  def self.minimum_booking
    15.minutes
  end

  private

  def booking_length
    if self.length < Booking::minimum_booking
      errors.add(:base, "#{Booking::minimum_booking.to_time_string} is the minimum booking length")
    end

    existing_booking_length = self.user.bookings.map(&:length).inject(0, &:+)
    if !self.user.nil? && (existing_booking_length + self.length) > Booking::booking_allowance
      errors.add(:base, "You can have #{Booking::booking_allowance.to_time_string} worth of active bookings in total, this booking would exceed that limit.")
      errors.add(:base, "Your current bookings take #{existing_booking_length.to_time_string} in total, you have #{(5.hours - existing_booking_length).to_time_string} left on your allowance.")
    end
  end

  def booking_datetime
    if self.begin < DateTime.now
      errors.add(:base, 'Booking start date and time must be in the future')
    end
  end

  def owner
    unless self.user.verified?
      errors.add(:base, 'You must first verify your email before you can make any bookings')
    end
  end

  def is_not_overlapping
    if self.status != GENERATED && !self.room.bookings.overlapping(self.begin, self.end).empty?
      errors.add(:base, 'Your booking is overlapping another booking on this room')
    end
  end
end
