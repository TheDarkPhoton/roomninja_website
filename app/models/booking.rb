class Booking < ActiveRecord::Base
  belongs_to :room
  belongs_to :user

  validates :begin, presence: true
  validates :end, presence: true

  DAYS = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)

  STATUSES = %w(Booked Expired Canceled)
  BOOKED = STATUSES[0]
  EXPIRED = STATUSES[1]
  CANCELED = STATUSES[2]

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
end
