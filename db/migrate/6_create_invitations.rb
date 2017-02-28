class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.string :list_id
      t.integer :invitation_id
      t.text :raw_data
      t.timestamps
    end
  end
end

