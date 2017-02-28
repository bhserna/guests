module Invitations
  def self.save_record(list_id, invitation, store)
    store.create(
      list_id: list_id,
      invitation_id: invitation["id"].to_i,
      raw_data: invitation)
  end

  def self.update_record(list_id, invitation, store)
    record = store.find_for_list_by_invitation_id(list_id, invitation["id"])
    store.update(record[:id],
      list_id: list_id,
      invitation_id: invitation["id"].to_i,
      raw_data: invitation)
  end

  def self.delete_record(list_id, invitation_id, store)
    record = store.find_for_list_by_invitation_id(list_id, invitation_id)
    store.delete(record[:id])
  end

  def self.fetch_records(list_id, store)
    store.find_for_list(list_id).map { |record| record[:raw_data] }
  end
end
