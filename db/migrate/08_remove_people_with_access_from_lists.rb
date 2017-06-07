class RemovePeopleWithAccessFromLists < ActiveRecord::Migration
  def change
    remove_column :lists, :people_with_access, :text
  end
end
