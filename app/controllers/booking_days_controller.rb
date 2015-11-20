class BookingDaysController < ApplicationController
  before_action :user_is_logged_in

  def index
    @current_time = Time.now

    user_rooms = current_user.institution.rooms
    @overlaps = user_rooms.overlapping_bookings2(
        Date.today, { begin: @current_time, end: @current_time + 1.hour }).collect { |r| r.id }
    @rooms = user_rooms.where.not(id: @overlaps)
  end

  def new
    @room = Room.find(params[:room_id])
    @booking_day = @room.booking_days.find_by(date: Date.today)
    @booking_day = @room.booking_days.build if @booking_day.nil?
    @booking_time = @booking_day.booking_times.build
  end

  def create
    @room = Room.find(params[:room_id])

    if params[:commit] == 'Book'
      @booking_day = @room.booking_days.find_by(date: Date.today)
      @booking_day = @room.booking_days.build if @booking_day.nil?
      @booking_time = @booking_day.booking_times.create(begin: Time.now, end: Time.now + 1.hour)
      current_user.booking_times << @booking_time

      @error = true unless @booking_time.save
    else
      @canceled = true
    end
  end

  def update
    @booking_day = BookingDay.find(params[:id])
    @room = @booking_day.room

    if params[:commit] == 'Book'
      @booking_time = @booking_day.booking_times.create(begin: Time.now, end: Time.now + 1.hour)
      current_user.booking_times << @booking_time

      @error = true unless @booking_time.save
    else
      @canceled = true
    end
  end

  def find
    @time_begin = parse_time_params(params[:room][:begin])
    @time_end = @time_begin + params[:room][:for_hours].to_i.hours + params[:room][:for_minutes].to_i.minutes
    @date_begin = parse_date_params(params[:room][:date])

    user_rooms = current_user.institution.rooms
    @overlaps = user_rooms.overlapping_bookings2(
        @date_begin, { begin: @time_begin, end: @time_end }).collect { |r| r.id }
    @rooms = user_rooms.where.not(id: @overlaps)

    render :index, :formats => [:js]
  end

  private

  def booking_time_params
  end

  def user_is_logged_in
    render js: "window.location = '#{root_url}'" unless logged_in?
  end
end
