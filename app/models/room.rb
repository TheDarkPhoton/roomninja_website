class Room < ActiveRecord::Base
  has_many :bookings, dependent: :destroy

  def generate_bookings

  end
end
