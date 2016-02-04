class AddPeopleToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :people, :integer
  end
end
