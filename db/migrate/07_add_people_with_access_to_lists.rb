class AddPeopleWithAccessToLists < ActiveRecord::Migration
  def change
    add_column :lists, :people_with_access, :text
  end
end
