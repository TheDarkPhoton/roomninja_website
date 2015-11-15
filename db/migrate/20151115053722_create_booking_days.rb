class CreateBookingDays < ActiveRecord::Migration
  def change
    create_table :booking_days do |t|
      t.string :day

      t.belongs_to :room, index: true
      t.timestamps null: false
    end
  end
end
