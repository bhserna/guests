class AddListIdToLists < ActiveRecord::Migration
  def change
    add_column :lists, :list_id, :string
  end
end
