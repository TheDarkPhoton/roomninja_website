class ChangeBookingDaysModel < ActiveRecord::Migration
  def change
    drop_table :booking_days
    create_table :booking_days do |t|
      t.string :day
      t.date :date

      t.belongs_to :room, index: true
      t.timestamps null: false
    end
  end
end
