class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :remember_digest

      t.string :activation_token
      t.boolean :is_verified

      t.string :reset_token
      t.datetime :reset_expire

      t.belongs_to :institution, index: true
      t.timestamps null: false
    end
  end
end
