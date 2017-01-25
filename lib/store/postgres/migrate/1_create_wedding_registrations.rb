class CreateWeddingRegistrations < ActiveRecord::Migration
  def change
    create_table :wedding_registrations do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :wedding_roll
      t.string :password_digest
    end
  end
end
