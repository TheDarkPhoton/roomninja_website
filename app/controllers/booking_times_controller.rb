class BookingTimesController < ApplicationController
  def index
  end

  def new
    @current = Time.now
    @booking_time = BookingTime.new

    @overlaps = Room.overlapping_bookings(@current).collect { |r| r.id }
    @rooms = Room.where.not(id: @overlaps)
  end

  def create
    @current = Time.now
    @room = Room.find_by(name: params[:name])
    booking_day = @room.booking_days.find_by(day: BookingDay::DAYS[@current.wday])
    booking_time = booking_day.booking_times.create(begin: @current, end: @current + 1.hour)
    booking_time.save

    current_user.booking_times << booking_time
  end
end
