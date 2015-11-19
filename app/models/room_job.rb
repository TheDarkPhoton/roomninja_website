class RoomJob
  require 'open-uri'
  include Delayed::RecurringJob

  run_every 1.hour
  queue 'slow-jobs'

  def perform
    Institution.all.each do |i|
      generate_rooms(i)
    end
  end

  private

  def generate_rooms(institution)
    data = JSON.load(open(institution.data))

    week_days = BookingDay::DAYS
    week_days << week_days.shift

    room_ids = []
    data['Rooms'].each do |room|
      r = institution.rooms.where(is_generated: true).find_by(internal_name: room['Name'].strip)
      r = Room.new(internal_name: room['Name'].strip, is_generated: true) if r.nil?

      room['Days'].each do |day|
        date = Date.today.at_beginning_of_week + week_days.index(day['Day'].strip).days
        bookings_generator(r, day, date)
      end

      r.save!
      room_ids << r.id
      institution.rooms << r if r.institution_id.nil?
    end
    institution.rooms.where(is_generated: true).where.not(id: room_ids).destroy_all
  end

  def bookings_generator(room, day, date)
    booking_day = room.booking_days.find_by(date: date)
    booking_day = room.booking_days.build(day: day['Day'].strip, date: date) if booking_day.nil?

    booking_times_saved = booking_day.booking_times.where(user_id: nil)
    bookings_processed = 0
    day['Activities'].each_with_index do |activities, index|
      if index >= booking_times_saved.count
        bookings_processed = index
        break
      end
      booking_times_saved[index].update_attributes(begin: activities['Start'], end: activities['End'])
      check_if_overlaps(booking_day, booking_times_saved[index])
    end

    if day['Activities'].count < booking_times_saved.count
      booking_times_saved.offset(day['Activities'].count).destroy_all
    elsif day['Activities'].count > booking_times_saved.count
      day['Activities'].drop(bookings_processed).each do |activities|
        booking_time = booking_day.booking_times.build(begin: activities['Start'], end: activities['End'])
        check_if_overlaps(booking_day, booking_time)
      end
    end

    booking_day.save!
  end

  def check_if_overlaps(booking_day, booking_time)
    booking_begin = Time.parse(booking_time.begin.to_s(:time))
    booking_end = Time.parse(booking_time.end.to_s(:time))

    overlaps = booking_day.booking_times.where.not(id: booking_time.id).where(
        '(? BETWEEN begin AND end) OR (? BETWEEN begin AND end) OR (? < begin AND ? > end)',
        booking_begin,
        booking_end,
        booking_begin,
        booking_end)

    overlaps.destroy_all
  end
end