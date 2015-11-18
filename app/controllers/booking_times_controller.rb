class BookingTimesController < ApplicationController
  before_action :user_is_logged_in

  def index

  end

  def new
    @current = Time.now
    @booking_time = BookingTime.new

    @overlaps = Room.overlapping_bookings(@current).collect { |r| r.id }
    @rooms = Room.where.not(id: @overlaps)
  end

  def create
    @room = Room.find_by(name: params[:name])
    @booking_day = BookingDay.find(params[:booking_day_id])

    @current = Time.now
    booking_time = @booking_day.booking_times.create(begin: @current, end: @current + 1.hour)
    booking_time.save

    current_user.booking_times << booking_time
  end

  private

  def user_is_logged_in

  end
end
