class Room < ActiveRecord::Base
  after_initialize :default_values, unless: :persisted?

  belongs_to :institution

  has_many :bookings, dependent: :destroy
  accepts_nested_attributes_for :bookings

  validates :internal_name, presence: true
  validates :description, presence: true
  validates :capacity, presence: true
  validates_inclusion_of :is_generated, in: [true, false]

  def name
    return self.alias unless self.alias.blank?
    self.internal_name
  end

  def self.invalid_bookings(begin_time, end_time, people)
    find_by_sql(['
      SELECT rooms.id
      FROM rooms
      WHERE rooms.capacity < (? + (SELECT COALESCE(sum(b1.people), 0)
                              FROM bookings AS b1
                              WHERE b1.room_id = rooms.id
                              AND (?, ?) OVERLAPS (begin_time::TIMESTAMP, end_time::TIMESTAMP)))
      GROUP BY rooms.id
    ', people, begin_time, end_time])
  end

  def count_people_at(begin_time, end_time)
    self.bookings.where('(?, ?) OVERLAPS (begin_time::TIMESTAMP, end_time::TIMESTAMP)', begin_time, end_time).sum(:people)
  end

  private

  def default_values
    self.description ||= 'No description provided.'
    self.capacity ||= 0
    self.is_generated ||= false
  end
end
