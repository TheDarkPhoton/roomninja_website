class BookingsController < ApplicationController
  require 'numeric'

  before_action :user_is_logged_in

  def index
    @find_rooms = FindRoom.new
    booking_end = @find_rooms.begin + @find_rooms.for_hours.hours + @find_rooms.for_minutes.minutes

    user_rooms = current_user.institution.rooms
    @overlaps = user_rooms.overlapping_bookings(@find_rooms.begin, booking_end).collect { |r| r.id }
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

    if params[:commit] == 'Book'
      @booking = @room.bookings.build(booking_params)
      booking_end = @booking.begin + @booking.for_hours.hours + @booking.for_minutes.minutes

      @booking.end = booking_end
      @booking.status = Booking::BOOKED
      @booking.user_id = current_user.id

      @error = true unless @booking.save
    else
      @find_rooms = FindRoom.new
      @canceled = true
    end
  end

  def destroy
    @booking = Booking.find(params[:id])
    @booking.destroy
  end

  def find
    @find_rooms = FindRoom.new(find_rooms_params)
    booking_end = @find_rooms.begin + @find_rooms.for_hours.hours + @find_rooms.for_minutes.minutes

    if @find_rooms.valid?
      user_rooms = current_user.institution.rooms.where('LOWER(internal_name) LIKE ? or LOWER(alias) LIKE ?', '%'+@find_rooms.name+'%', '%'+@find_rooms.name+'%')
      @overlaps = user_rooms.overlapping_bookings(@find_rooms.begin, booking_end).collect { |r| r.id }
      @rooms = user_rooms.where.not(id: @overlaps)
      render :index, :formats => [:js]
    end
  end

  private

  def find_rooms_params
    params[:find_room][:for_hours] = params[:find_room][:for_hours].to_i
    params[:find_room][:for_minutes] = params[:find_room][:for_minutes].to_i
    parse_datetime_params(params[:find_room], :begin)
    params.require(:find_room).permit(:name, :begin, :for_hours, :for_minutes)
  end

  def booking_params
    params[:booking][:for_hours] = params[:booking][:for_hours].to_i
    params[:booking][:for_minutes] = params[:booking][:for_minutes].to_i
    params.require(:booking).permit(:begin, :for_hours, :for_minutes)
  end

  def user_is_logged_in
    unless logged_in? && @current_user.id != params[:id]
      flash[:danger] = "You don't have permission for this action"
      respond_to { |f|
        f.js { render js: "window.location = '#{root_url}'" }
        f.html { redirect_to root_url }
      }
    end
  end
end
