class StaticController < ApplicationController
  def show
    @current = Time.now

    @overlaps = Room.overlapping_bookings(@current).collect { |r| r.id }
    @rooms = Room.where.not(id: @overlaps)
  end
end