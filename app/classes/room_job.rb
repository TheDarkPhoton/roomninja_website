class RoomJob
  require 'open-uri'
  include Delayed::RecurringJob

  run_every 1.minute
  queue 'slow-jobs'

  def perform
    Institution.all.each do |i|
      generate_rooms(i) unless i.data.blank?
    end
  end

  private

  def generate_rooms(institution)
    # data = JSON.load(open('http://www.inf.kcl.ac.uk/staff/andrew/rooms/somerooms.json'))
    data = JSON.load(open(institution.data))

    week_days = Booking::DAYS
    week_days << week_days.shift

    room_ids = []
    data['Rooms'].each do |room|
      r = institution.rooms.where(is_generated: true).find_by(internal_name: room['Name'].strip)
      r = Room.new(internal_name: room['Name'].strip, is_generated: true) if r.nil?
      r.capacity = 1

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
    saved_bookings = room.bookings.where(user_id: nil).where('? < begin_time AND ? > begin_time', date, date + 1.day)

    update_count = 0
    day['Activities'].each_with_index do |activity, index|
      if index >= saved_bookings.count
        update_count = index
        break
      end

      begin_date = DateTime.parse("#{date.to_s}T#{activity['Start']}")
      end_date = DateTime.parse("#{date.to_s}T#{activity['End']}")

      saved_bookings[index].update_attributes(
          begin_time: begin_date,
          end_time: end_date,
          people: room.capacity,
          status: Booking::GENERATED)

      check_if_overlaps(
          room,
          saved_bookings[index])
    end

    if day['Activities'].count < saved_bookings.count
      saved_bookings.offset(day['Activities'].count).destroy_all
    elsif day['Activities'].count > saved_bookings.count
      day['Activities'].drop(update_count).each do |activity|
        begin_date = DateTime.parse("#{date.to_s}T#{activity['Start']}")
        end_date = DateTime.parse("#{date.to_s}T#{activity['End']}")

        booking = room.bookings.build(
            begin_time: begin_date,
            end_time: end_date,
            people: room.capacity,
            status: Booking::GENERATED)
        booking.save!

        check_if_overlaps(room, booking)
      end
    end
  end

  def check_if_overlaps(room, booking)
    booking_begin = booking.begin_time.to_s(:db)
    booking_end = booking.end_time.to_s(:db)

    room.bookings.where.not(id: booking.id).where('user_id IS NOT NULL').overlapping(booking_begin, booking_end).destroy_all
  end
end