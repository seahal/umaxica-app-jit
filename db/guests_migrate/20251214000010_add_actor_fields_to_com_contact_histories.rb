class AddActorFieldsToComContactHistories < ActiveRecord::Migration[8.2]
  def change
    change_table :com_contact_histories, bulk: true do |t|
      t.uuid :actor_id, if_not_exists: true
      t.string :actor_type, if_not_exists: true
    end
  end
end
