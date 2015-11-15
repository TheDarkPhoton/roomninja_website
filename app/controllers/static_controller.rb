class StaticController < ApplicationController
  require 'open-uri'

  def index
    @current = Time.now

    @data = JSON.load(open('http://www.inf.kcl.ac.uk/staff/andrew/rooms/somerooms.json'))

    @overlaps = Room.overlapping_bookings(@current).collect { |r| r.id }
    @rooms = Room.where.not(id: @overlaps)
  end
end