class RoomJob
  require 'open-uri'
  include Delayed::RecurringJob

  run_every 1.hour
  queue 'slow-jobs'

  def perform
    data = JSON.load(open('http://www.inf.kcl.ac.uk/staff/andrew/rooms/somerooms.json'))

    room_ids = []
    data['Rooms'].each do |room|
      r = Room.where(is_generated: true).find_by(name: room['Name'].strip)
      r = Room.new(name: room['Name'].strip, is_generated: true) if r.nil?
      room_ids << r.id

      room['Days'].each do |day|
        booking_day = r.booking_days.find_by(day: day['Day'].strip)

        booking_time_ids = []
        booking_times_saved = booking_day.booking_times
        bookings_processed = 0
        day['Activities'].each_with_index do |activities, index|
          if index >= booking_times_saved.count
            bookings_processed = index
            break
          end
          booking_times_saved[index].update_attributes(begin: activities['Start'], end: activities['End'])
          check_if_overlaps(booking_times_saved[index])

          booking_time_ids << booking_times_saved[index].id
        end

        if day['Activities'].count < booking_times_saved.count
          booking_times_saved.drop(day['Activities'].count).where(user_id: nil).destroy_all
        elsif day['Activities'].count > booking_times_saved.count
          day['Activities'].drop(bookings_processed).each do |activities|
            booking_time = booking_day.booking_times.build(begin: activities['Start'], end: activities['End'])
            check_if_overlaps(booking_time)
          end
        end

        booking_day.save!
      end

      r.save!
    end
    Room.where(is_generated: true).where.not(id: room_ids).destroy_all
  end

  private

  def check_if_overlaps(booking_time)
    booking_begin = Time.parse(booking_time.begin.to_s(:time))
    booking_end = Time.parse(booking_time.end.to_s(:time))

    overlaps = BookingTime.where.not(id: booking_time.id).where(
        '(? BETWEEN begin AND end) OR (? BETWEEN begin AND end) OR (? < begin AND ? > end)',
        booking_begin,
        booking_end,
        booking_begin,
        booking_end)

    overlaps.destroy_all
  end
end