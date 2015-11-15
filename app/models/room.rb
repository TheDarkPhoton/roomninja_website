class Room < ActiveRecord::Base
  require 'open-uri'

  has_many :booking_days, dependent: :destroy
  accepts_nested_attributes_for :booking_days

  validates :name, presence: true

  def self.generate_bookings
    Room.destroy_all

    data = JSON.load(open('http://www.inf.kcl.ac.uk/staff/andrew/rooms/somerooms.json'))
    data['Rooms'].each do |room|
      r = Room.new(name: room['Name'])

      room['Days'].each do |day|
        booking = r.booking_days.build(day: day['Day'])

        day['Activities'].each do |activities|
          booking.booking_times.build(begin: activities['Start'], end: activities['End'])
        end
      end

      r.save!
    end
  end

  def self.overlapping_bookings(time)
    joins('INNER JOIN booking_days ON booking_days.room_id = rooms.id LEFT OUTER JOIN booking_times ON booking_days.id = booking_times.booking_day_id')
        .where(booking_days: { day: BookingDay::DAYS[time.wday] })
        .where('? BETWEEN booking_times.begin AND booking_times.end', time)
        .group(:name)
  end
end
