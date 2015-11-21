class BookingsController < ApplicationController
  before_action :user_is_logged_in

  def index
    @begin = DateTime.now
    @for_hours = 1
    @for_minutes = 0

    user_rooms = current_user.institution.rooms
    @overlaps = user_rooms.overlapping_bookings(@begin, @begin + @for_hours.hours).collect { |r| r.id }
    @rooms = user_rooms.where.not(id: @overlaps)
  end

  def new
    @room = Room.find(params[:room_id])

    @begin = DateTime.parse(params[:begin])
    @booking = @room.bookings.build(
        begin: @begin,
        for_hours: params[:for_hours],
        for_minutes: params[:for_minutes])
  end

  def create
    @room = Room.find(params[:room_id])

    @begin = parse_datetime_params(params[:booking], :begin)
    @for_hours = params[:booking][:for_hours].to_i
    @for_minutes = params[:booking][:for_minutes].to_i

    if params[:commit] == 'Book'
      @booking = @room.bookings.build(begin: @begin, end: @begin + @for_hours.hours + @for_minutes.minutes, status: Booking::BOOKED)
      @booking.user_id = current_user.id
      @booking.for_hours = @for_hours
      @booking.for_minutes = @for_minutes

      @error = true unless @booking.save
    else
      @canceled = true
    end
  end

  def destroy
    @booking = Booking.find(params[:id])
    @booking.destroy
  end

  def find
    @begin = parse_datetime_params(params[:room], :begin)
    @for_hours = params[:room][:for_hours].to_i
    @for_minutes = params[:room][:for_minutes].to_i
    @end_time = @begin + @for_hours.hours + @for_minutes.minutes

    user_rooms = current_user.institution.rooms.where('internal_name LIKE ? or alias LIKE ?', '%'+params[:room][:name]+'%', '%'+params[:room][:name]+'%')

    @overlaps = user_rooms.overlapping_bookings(@begin, @end_time).collect { |r| r.id }
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
