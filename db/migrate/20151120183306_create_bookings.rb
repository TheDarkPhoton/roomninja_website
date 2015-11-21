class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.datetime :begin
      t.datetime :end
      t.string :status

      t.belongs_to :room, index: true
      t.belongs_to :user, index: true
      t.timestamps null: false
    end
  end
end
