class CreateInstitutions < ActiveRecord::Migration
  def change
    create_table :institutions do |t|
      t.string :name
      t.string :domain
      t.string :data

      t.timestamps null: false
    end
  end
end
