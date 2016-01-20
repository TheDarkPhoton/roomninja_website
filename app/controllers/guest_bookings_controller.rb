class GuestBookingsController < ApplicationController

  def index
    @find_rooms = FindRoom.new

    user_rooms = current_user.institution.rooms
    @overlaps = user_rooms.invalid_bookings(@find_rooms.begin_time, @find_rooms.end_time, @find_rooms.people).collect { |r| r.id }
    @rooms = user_rooms.where.not(id: @overlaps)
  end

  def new
    @room = Room.find(params[:room_id])

    @begin = DateTime.parse(params[:begin_time])
    @booking = @room.bookings.build(
        people: params[:people],
        begin_time: @begin,
        for_hours: params[:for_hours],
        for_minutes: params[:for_minutes])
  end

  def create
    @room = Room.find(params[:room_id])

    if params[:commit] == 'Book'
      @booking = @room.bookings.build(booking_params)
      @booking.calculate_end_time

      @booking.status = Booking::BOOKED

      @error = true unless @booking.save
    else
      @find_rooms = FindRoom.new(find_rooms_params(:booking))
      @canceled = true
    end
  end

  def find
    @find_rooms = FindRoom.new(find_rooms_params)

    if @find_rooms.valid?
      user_rooms = current_user.institution.rooms.where('LOWER(internal_name) LIKE ? or LOWER(alias) LIKE ?', '%'+@find_rooms.name+'%', '%'+@find_rooms.name+'%')
      @overlaps = user_rooms.invalid_bookings(@find_rooms.begin_time, @find_rooms.end_time, @find_rooms.people).collect { |r| r.id }
      @rooms = user_rooms.where.not(id: @overlaps)
      render :index, :formats => [:js]
    end
  end

  private

  def find_rooms_params(symbol = :find_room)
    params[symbol][:for_hours] = params[symbol][:for_hours].to_i
    params[symbol][:for_minutes] = params[symbol][:for_minutes].to_i
    parse_datetime_params(params[symbol], :begin_time)
    params.require(symbol).permit(:name, :people, :begin_time, :for_hours, :for_minutes)
  end

  def booking_params
    params[:booking][:for_hours] = params[:booking][:for_hours].to_i
    params[:booking][:for_minutes] = params[:booking][:for_minutes].to_i
    params.require(:booking).permit(:people, :begin_time, :for_hours, :for_minutes)
  end
end
