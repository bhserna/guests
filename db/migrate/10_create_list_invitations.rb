class CreateListInvitations < ActiveRecord::Migration
  def change
    create_table :list_invitations do |t|
      t.string :list_id
      t.string :title
      t.text :guests
      t.string :email
      t.string :phone
      t.boolean :is_delivered
      t.integer :confirmed_guests_count
      t.boolean :is_assistance_confirmed
      t.boolean :is_deleted
      t.timestamps
    end
  end
end
