class BookingTimesController < ApplicationController
  before_action :user_is_logged_in

  def index
    @current_time = Time.now
    @overlaps = Room.overlapping_bookings(@current_time).collect { |r| r.id }
    @rooms = Room.where.not(id: @overlaps)
  end

  def new
    @room = Room.find(params[:room_id])
    @booking_day = BookingDay.find(params[:booking_day_id])
    @booking_time = BookingTime.new
  end

  def create
    @current_time = Time.now
    @room = Room.find(params[:room_id])
    @booking_day = BookingDay.find(params[:booking_day_id])

    if params[:commit] == 'Book'
      booking_time = @booking_day.booking_times.create(begin: @current_time, end: @current_time + 1.hour)
      if booking_time.save
        current_user.booking_times << booking_time
      else
        @error = true
      end
    else
      @canceled = true
    end
  end

  private

  def user_is_logged_in

  end
end
