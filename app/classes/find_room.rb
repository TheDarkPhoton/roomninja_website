class FindRoom
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks

  attr_accessor :name, :begin_time, :for_hours, :for_minutes

  validates :begin_time, presence: true
  validates :for_hours, presence: true
  validates :for_minutes, presence: true
  validate :booking_datetime
  validate :booking_length

  def initialize(attributes = {})
    super(attributes)
    default_values
  end

  def length
    self.for_hours.hours + self.for_minutes.minutes
  end

  def form_name
    'Find rooms'
  end

  private

  def default_values
    self.name ||= ''
    self.begin_time ||= DateTime.now + 15.minutes
    self.for_hours ||= 1
    self.for_minutes ||= 0

    self.name = self.name.downcase
  end

  def booking_length
    if self.length < Booking::minimum_booking
      errors.add(:base, "#{Booking::minimum_booking.to_time_string} is the minimum booking length")
    end
  end

  def booking_datetime
    if self.begin_time < DateTime.now
      errors.add(:base, "You can't search for bookings in the past, past bookings are not allowed")
    end
  end
end