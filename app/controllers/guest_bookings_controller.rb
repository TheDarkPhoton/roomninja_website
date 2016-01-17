class GuestBookingsController < ApplicationController

  def index
    @find_rooms = FindRoom.new
    booking_end = @find_rooms.begin_time + @find_rooms.for_hours.hours + @find_rooms.for_minutes.minutes

    user_rooms = Room.all
    @overlaps = user_rooms.overlapping_bookings(@find_rooms.begin_time, booking_end).collect { |r| r.id }
    @rooms = user_rooms.where.not(id: @overlaps)
  end

  def new
    @room = Room.find(params[:room_id])

    @begin = DateTime.parse(params[:begin_time])
    @booking = @room.bookings.build(
        begin_time: @begin,
        for_hours: params[:for_hours],
        for_minutes: params[:for_minutes])
  end

  def create
    @room = Room.find(params[:room_id])

    if params[:commit] == 'Book'
      @booking = @room.bookings.build(booking_params)
      booking_end = @booking.begin_time + @booking.for_hours.hours + @booking.for_minutes.minutes

      @booking.end_time = booking_end
      @booking.status = Booking::BOOKED

      @error = true unless @booking.save
    else
      @find_rooms = FindRoom.new
      @canceled = true
    end
  end

  def find
    @find_rooms = FindRoom.new(find_rooms_params)
    booking_end = @find_rooms.begin_time + @find_rooms.for_hours.hours + @find_rooms.for_minutes.minutes

    if @find_rooms.valid?
      user_rooms = Room.where('LOWER(internal_name) LIKE ? or LOWER(alias) LIKE ?', '%'+@find_rooms.name+'%', '%'+@find_rooms.name+'%')
      @overlaps = user_rooms.overlapping_bookings(@find_rooms.begin_time, booking_end).collect { |r| r.id }
      @rooms = user_rooms.where.not(id: @overlaps)
      render :index, :formats => [:js]
    end
  end

  private

  def find_rooms_params
    params[:find_room][:for_hours] = params[:find_room][:for_hours].to_i
    params[:find_room][:for_minutes] = params[:find_room][:for_minutes].to_i
    parse_datetime_params(params[:find_room], :begin_time)
    params.require(:find_room).permit(:name, :begin_time, :for_hours, :for_minutes)
  end

  def booking_params
    params[:booking][:for_hours] = params[:booking][:for_hours].to_i
    params[:booking][:for_minutes] = params[:booking][:for_minutes].to_i
    params.require(:booking).permit(:begin_time, :for_hours, :for_minutes)
  end
end
