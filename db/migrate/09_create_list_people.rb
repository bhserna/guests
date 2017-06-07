class CreateListPeople < ActiveRecord::Migration
  def change
    create_table :list_people do |t|
      t.string :list_id
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :wedding_roll
      t.timestamps
    end
  end
end
