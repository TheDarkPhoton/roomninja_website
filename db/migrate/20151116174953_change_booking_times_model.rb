class ChangeBookingTimesModel < ActiveRecord::Migration
  def change
    drop_table :booking_times
    create_table :booking_times do |t|
      t.time :begin
      t.time :end
      t.string :status

      t.belongs_to :booking_day, index: true
      t.belongs_to :user, index: true
      t.timestamps null: false
    end
  end
end
