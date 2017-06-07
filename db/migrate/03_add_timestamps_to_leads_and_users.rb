class AddTimestampsToLeadsAndUsers < ActiveRecord::Migration
  def change
    add_timestamps :leads
    add_timestamps :users
  end
end

