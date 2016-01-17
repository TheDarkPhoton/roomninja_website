class Booking < ActiveRecord::Base
  require 'numeric'

  attr_accessor :for_hours
  attr_accessor :for_minutes

  belongs_to :room
  belongs_to :user

  validates :begin_time, presence: true
  validates :end_time, presence: true
  validate :is_not_overlapping, unless: Proc.new { self.status == GENERATED }
  validate :booking_length, unless: Proc.new { self.status == GENERATED }
  validate :booking_datetime, unless: Proc.new { self.status == GENERATED }
  validate :owner, unless: Proc.new { self.status == GENERATED }

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
      DAYS[self.begin_time.wday]
    rescue => e
      return nil
    end
  end

  def length
    self.end_time.to_i - self.begin_time.to_i
  end

  def self.overlapping(begin_time, end_time)
    where('(?, ?) OVERLAPS (begin_time::TIMESTAMP, end_time::TIMESTAMP)', begin_time, end_time)
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

    if self.user.nil?
      if self.length > 1.hour
        errors.add(:base, 'Guests are not allowed to make bookings exceeding 1 hour')
      end
    else
      existing_booking_length = self.user.bookings.map(&:length).inject(0, &:+)
      if !self.user.nil? && (existing_booking_length + self.length) > Booking::booking_allowance # TODO remove first clause probably
        # errors.add(:base, "You can have #{Booking::booking_allowance.to_time_string} worth of active bookings in total, this booking would exceed that limit.")
        errors.add(:base, "Your current bookings take #{existing_booking_length.to_time_string} in total, you have #{(5.hours - existing_booking_length).to_time_string} left on your allowance.")
      end
    end
  end

  def booking_datetime
    if self.begin_time < DateTime.now
      errors.add(:base, 'Booking start date and time must be in the future')
    end
  end

  def owner
    return if self.user.nil?
    unless self.user.verified?
      errors.add(:base, 'You must first verify your email before you can make any bookings')
    end
  end

  def is_not_overlapping
    unless self.room.bookings.overlapping(self.begin_time, self.end_time).empty?
      errors.add(:base, 'Your booking is overlapping another booking on this room')
    end
  end
end
