class StaticController < ApplicationController
  require 'open-uri'

  def index
    @current = Time.now

    @data = JSON.load(open('http://www.inf.kcl.ac.uk/staff/andrew/rooms/somerooms.json'))

    @overlaps = Room.joins('INNER JOIN booking_days ON booking_days.room_id = rooms.id LEFT OUTER JOIN booking_times ON booking_days.id = booking_times.booking_day_id')
                 .where(booking_days: { day: BookingDay::DAYS[@current.wday] })
                 .where('? BETWEEN booking_times.begin AND booking_times.end', @current)
                 .group(:name).collect { |r| r.id }

    @rooms = Room.joins('INNER JOIN booking_days ON booking_days.room_id = rooms.id LEFT OUTER JOIN booking_times ON booking_days.id = booking_times.booking_day_id')
                 .where(booking_days: { day: BookingDay::DAYS[@current.wday] })
                 .where('booking_times.booking_day_id IS NULL OR ? NOT BETWEEN booking_times.begin AND booking_times.end', @current)
                 .group(:name).where.not(id: @overlaps)

  end
end