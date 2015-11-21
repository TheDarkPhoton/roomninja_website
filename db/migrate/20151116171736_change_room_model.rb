class ChangeRoomModel < ActiveRecord::Migration
  def change
    drop_table :rooms
    create_table :rooms do |t|
      t.string :internal_name
      t.string :alias
      t.string :description
      t.integer :capacity

      t.boolean :is_generated

      t.belongs_to :institution, index: true
      t.timestamps null: false
    end
  end
end
