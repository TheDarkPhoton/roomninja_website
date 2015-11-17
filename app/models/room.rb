class Room < ActiveRecord::Base
  after_initialize :default_values, unless: :persisted?

  belongs_to :institution

  has_many :booking_days, dependent: :destroy
  accepts_nested_attributes_for :booking_days

  validates :name, presence: true
  validates :description, presence: true
  validates :capacity, presence: true
  validates_inclusion_of :is_generated, in: [true, false]

  def self.overlapping_bookings(time)
    joins('INNER JOIN booking_days ON booking_days.room_id = rooms.id LEFT OUTER JOIN booking_times ON booking_days.id = booking_times.booking_day_id')
        .where(booking_days: { day: BookingDay::DAYS[time.wday] })
        .where('? BETWEEN booking_times.begin AND booking_times.end', time)
        .group(:name)
  end

  private

  def default_values
    self.description ||= 'No description provided.'
    self.capacity ||= 0
    self.is_generated ||= false

    BookingDay::DAYS.each do |d|
      self.booking_days.build(day: d)
    end
    self.save
  end
end
