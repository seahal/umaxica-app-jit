class AddMissingIndexesToBusinesses < ActiveRecord::Migration[8.2]
  def change
    # Polymorphic Audits
    add_index :app_document_audits, [ :actor_type, :actor_id ], if_not_exists: true
    add_index :app_timeline_audits, [ :actor_type, :actor_id ], if_not_exists: true
    add_index :com_document_audits, [ :actor_type, :actor_id ], if_not_exists: true
    add_index :com_timeline_audits, [ :actor_type, :actor_id ], if_not_exists: true
    add_index :org_document_audits, [ :actor_type, :actor_id ], if_not_exists: true
    add_index :org_timeline_audits, [ :actor_type, :actor_id ], if_not_exists: true

    # Documents and Timelines (Adjacency + Status)
    %w[
      app_document
      app_timeline
      com_document
      com_timeline
      org_document
      org_timeline
    ].each do |prefix|
      table_name = :"#{prefix}s"
      add_index table_name, :parent_id, if_not_exists: true
      add_index table_name, :prev_id, if_not_exists: true
      add_index table_name, :succ_id, if_not_exists: true
      add_index table_name, :staff_id, if_not_exists: true
      add_index table_name, :"#{prefix}_status_id", if_not_exists: true
    end
  end
end
