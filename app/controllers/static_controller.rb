class StaticController < ApplicationController
  def home
    @find_rooms = FindRoom.new
  end
end