class BookingsController < ApplicationController
  before_action :user_is_logged_in

  def index
    @datetime = DateTime.now

    user_rooms = current_user.institution.rooms
    @overlaps = user_rooms.overlapping_bookings(@datetime, @datetime + 1.hour).collect { |r| r.id }
    @rooms = user_rooms.where.not(id: @overlaps)
  end

  def new
    @room = Room.find(params[:room_id])
    @booking = @room.bookings.build
  end

  def create
    @room = Room.find(params[:room_id])

    if params[:commit] == 'Book'
      @booking = @room.bookings.create(begin: DateTime.now, end: DateTime.now + 1.hour, status: Booking::BOOKED)
      current_user.bookings << @booking

      @error = true unless @booking.save
    else
      @canceled = true
    end
  end

  def find
    @datetime = parse_datetime_params(params[:room], :begin)
    @end_time = @datetime + params[:room][:for_hours].to_i.hours + params[:room][:for_minutes].to_i.minutes

    user_rooms = current_user.institution.rooms.where('internal_name LIKE ? or alias LIKE ?', '%'+params[:room][:name]+'%', '%'+params[:room][:name]+'%')

    @overlaps = user_rooms.overlapping_bookings(@datetime, @end_time).collect { |r| r.id }
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
