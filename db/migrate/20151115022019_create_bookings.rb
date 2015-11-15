class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.string :day
      t.time :start
      t.time :end

      t.belongs_to :rooms, index: true
      t.timestamps null: false
    end
  end
end
