class CreateBookingTimes < ActiveRecord::Migration
  def change
    create_table :booking_times do |t|
      t.time :begin
      t.time :end

      t.belongs_to :booking_day, index: true
      t.timestamps null: false
    end
  end
end
