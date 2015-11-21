class Booking < ActiveRecord::Base
  attr_accessor :for_hours
  attr_accessor :for_minutes

  belongs_to :room
  belongs_to :user

  validates :begin, presence: true
  validates :end, presence: true
  validate :is_not_overlapping

  DAYS = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)

  STATUSES = %w(Generated Booked Expired Canceled)
  GENERATED = STATUSES[0]
  BOOKED = STATUSES[1]
  EXPIRED = STATUSES[2]
  CANCELED = STATUSES[3]

  validates_inclusion_of :status, in: STATUSES

  def day
    begin
      DAYS[self.begin.wday]
    rescue => e
      return nil
    end
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

  private

  def is_not_overlapping
    if self.status != GENERATED && !self.room.bookings.overlapping(self.begin, self.end).empty?
      errors.add(:base, 'Your booking is overlapping another booking on this room')
    end
  end
end
