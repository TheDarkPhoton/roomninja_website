class RoomJob
  include Delayed::RecurringJob

  run_every 1.hour
  queue 'slow-jobs'

  def perform
    Room.destroy_all

    data = JSON.load(open('http://www.inf.kcl.ac.uk/staff/andrew/rooms/allrooms.json'))

    data['Rooms'].each do |room|
      r = Room.new(name: room['Name'])

      room['Days'].each do |day|
        booking = r.booking_days.build(day: day['Day'])

        day['Activities'].each do |activities|
          booking.booking_times.build(begin: activities['Start'], end: activities['End'])
        end
      end

      r.save!
    end
  end
end