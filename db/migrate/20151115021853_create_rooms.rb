class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.string :internal_name
      t.string :alias

      t.timestamps null: false
    end
  end
end
