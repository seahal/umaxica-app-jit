class AddActorFieldsToComContactHistories < ActiveRecord::Migration[8.2]
  def change
    change_table :com_contact_histories, bulk: true do |t|
      t.uuid :actor_id unless t.column_exists?(:actor_id)
      t.string :actor_type unless t.column_exists?(:actor_type)
    end
  end
end
