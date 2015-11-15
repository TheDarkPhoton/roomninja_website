class BookingTimesController < ApplicationController
  def index
  end

  def new
    @current = Time.now
    @booking_time = BookingTime.new
    @rooms = Room.joins('INNER JOIN booking_days ON booking_days.room_id = rooms.id LEFT OUTER JOIN booking_times ON booking_days.id = booking_times.booking_day_id')
                 .where(booking_days: { day: BookingDay::DAYS[@current.wday] })
                 .where('booking_times.booking_day_id IS NULL OR ? NOT BETWEEN booking_times.begin AND booking_times.end', @current)
                 .group(:name)

  end

  def create
    @current = Time.now
    @room = Room.find_by(name: params[:name])
    booking_day = @room.booking_days.find_by(day: BookingDay::DAYS[@current.wday])
    booking_time = booking_day.booking_times.create(begin: @current, end: @current + 1.minute)
    booking_time.save
  end
end
