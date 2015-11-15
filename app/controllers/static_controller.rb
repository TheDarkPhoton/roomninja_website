class StaticController < ApplicationController
  def index
    @current = Time.now

    @overlaps = Room.overlapping_bookings(@current).collect { |r| r.id }
    @rooms = Room.where.not(id: @overlaps)
  end
end