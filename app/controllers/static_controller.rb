class StaticController < ApplicationController
  def show
    @current_time = Time.now

    @overlaps = Room.overlapping_bookings(@current_time).collect { |r| r.id }
    @rooms = Room.where.not(id: @overlaps)
  end
end