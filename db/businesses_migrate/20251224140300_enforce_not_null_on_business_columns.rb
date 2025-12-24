class EnforceNotNullOnBusinessColumns < ActiveRecord::Migration[8.2]
  INFINITY_PAST = '-infinity'
  NIL_UUID = '00000000-0000-0000-0000-000000000000'

  def change
    # document_audits: actor_id, actor_type, current_value, ip_address, previous_value, timestamp
    %w[app_document_audits com_document_audits org_document_audits].each do |table|
      reversible do |dir|
        dir.up do
          execute "UPDATE #{table} SET actor_id = '#{NIL_UUID}' WHERE actor_id IS NULL"
          execute "UPDATE #{table} SET actor_type = '' WHERE actor_type IS NULL"
          execute "UPDATE #{table} SET current_value = '' WHERE current_value IS NULL"
          execute "UPDATE #{table} SET ip_address = '' WHERE ip_address IS NULL"
          execute "UPDATE #{table} SET previous_value = '' WHERE previous_value IS NULL"
          execute "UPDATE #{table} SET timestamp = '#{INFINITY_PAST}' WHERE timestamp IS NULL"
        end
      end

      change_table table.to_sym, bulk: true do |t|
        t.change_null :actor_id, false, NIL_UUID
        t.change_default :actor_id, from: nil, to: NIL_UUID

        t.change_null :actor_type, false, ''
        t.change_default :actor_type, from: nil, to: ''

        t.change_null :current_value, false, ''
        t.change_default :current_value, from: nil, to: ''

        t.change_null :ip_address, false, ''
        t.change_default :ip_address, from: nil, to: ''

        t.change_null :previous_value, false, ''
        t.change_default :previous_value, from: nil, to: ''

        t.change_null :timestamp, false, INFINITY_PAST
        t.change_default :timestamp, from: nil, to: -> { "'-infinity'::timestamp" }
      end
    end

    # documents: status_id, description, parent_id, prev_id, staff_id, succ_id, title
    [
      { prefix: 'app', status_col: :app_document_status_id },
      { prefix: 'com', status_col: :com_document_status_id },
      { prefix: 'org', status_col: :org_document_status_id }
    ].each do |config|
      table = :"#{config[:prefix]}_documents"

      reversible do |dir|
        dir.up do
          execute "UPDATE #{table} SET #{config[:status_col]} = '' WHERE #{config[:status_col]} IS NULL"
          execute "UPDATE #{table} SET description = '' WHERE description IS NULL"
          execute "UPDATE #{table} SET parent_id = '#{NIL_UUID}' WHERE parent_id IS NULL"
          execute "UPDATE #{table} SET prev_id = '#{NIL_UUID}' WHERE prev_id IS NULL"
          execute "UPDATE #{table} SET staff_id = '#{NIL_UUID}' WHERE staff_id IS NULL"
          execute "UPDATE #{table} SET succ_id = '#{NIL_UUID}' WHERE succ_id IS NULL"
          execute "UPDATE #{table} SET title = '' WHERE title IS NULL"
        end
      end

      change_table table, bulk: true do |t|
        t.change_null config[:status_col], false, ''
        t.change_default config[:status_col], from: nil, to: ''

        t.change_null :description, false, ''
        t.change_default :description, from: nil, to: ''

        t.change_null :parent_id, false, NIL_UUID
        t.change_default :parent_id, from: nil, to: NIL_UUID

        t.change_null :prev_id, false, NIL_UUID
        t.change_default :prev_id, from: nil, to: NIL_UUID

        t.change_null :staff_id, false, NIL_UUID
        t.change_default :staff_id, from: nil, to: NIL_UUID

        t.change_null :succ_id, false, NIL_UUID
        t.change_default :succ_id, from: nil, to: NIL_UUID

        t.change_null :title, false, ''
        t.change_default :title, from: nil, to: ''
      end
    end

    # timeline_audits: actor_id, actor_type, current_value, ip_address, previous_value, timestamp
    %w[app_timeline_audits com_timeline_audits org_timeline_audits].each do |table|
      reversible do |dir|
        dir.up do
          execute "UPDATE #{table} SET actor_id = '#{NIL_UUID}' WHERE actor_id IS NULL"
          execute "UPDATE #{table} SET actor_type = '' WHERE actor_type IS NULL"
          execute "UPDATE #{table} SET current_value = '' WHERE current_value IS NULL"
          execute "UPDATE #{table} SET ip_address = '' WHERE ip_address IS NULL"
          execute "UPDATE #{table} SET previous_value = '' WHERE previous_value IS NULL"
          execute "UPDATE #{table} SET timestamp = '#{INFINITY_PAST}' WHERE timestamp IS NULL"
        end
      end

      change_table table.to_sym, bulk: true do |t|
        t.change_null :actor_id, false, NIL_UUID
        t.change_default :actor_id, from: nil, to: NIL_UUID

        t.change_null :actor_type, false, ''
        t.change_default :actor_type, from: nil, to: ''

        t.change_null :current_value, false, ''
        t.change_default :current_value, from: nil, to: ''

        t.change_null :ip_address, false, ''
        t.change_default :ip_address, from: nil, to: ''

        t.change_null :previous_value, false, ''
        t.change_default :previous_value, from: nil, to: ''

        t.change_null :timestamp, false, INFINITY_PAST
        t.change_default :timestamp, from: nil, to: -> { "'-infinity'::timestamp" }
      end
    end

    # timelines: status_id, description, parent_id, prev_id, staff_id, succ_id, title
    [
      { prefix: 'app', status_col: :app_timeline_status_id },
      { prefix: 'com', status_col: :com_timeline_status_id },
      { prefix: 'org', status_col: :org_timeline_status_id }
    ].each do |config|
      table = :"#{config[:prefix]}_timelines"

      reversible do |dir|
        dir.up do
          execute "UPDATE #{table} SET #{config[:status_col]} = '' WHERE #{config[:status_col]} IS NULL"
          execute "UPDATE #{table} SET description = '' WHERE description IS NULL"
          execute "UPDATE #{table} SET parent_id = '#{NIL_UUID}' WHERE parent_id IS NULL"
          execute "UPDATE #{table} SET prev_id = '#{NIL_UUID}' WHERE prev_id IS NULL"
          execute "UPDATE #{table} SET staff_id = '#{NIL_UUID}' WHERE staff_id IS NULL"
          execute "UPDATE #{table} SET succ_id = '#{NIL_UUID}' WHERE succ_id IS NULL"
          execute "UPDATE #{table} SET title = '' WHERE title IS NULL"
        end
      end

      change_table table, bulk: true do |t|
        t.change_null config[:status_col], false, ''
        t.change_default config[:status_col], from: nil, to: ''

        t.change_null :description, false, ''
        t.change_default :description, from: nil, to: ''

        t.change_null :parent_id, false, NIL_UUID
        t.change_default :parent_id, from: nil, to: NIL_UUID

        t.change_null :prev_id, false, NIL_UUID
        t.change_default :prev_id, from: nil, to: NIL_UUID

        t.change_null :staff_id, false, NIL_UUID
        t.change_default :staff_id, from: nil, to: NIL_UUID

        t.change_null :succ_id, false, NIL_UUID
        t.change_default :succ_id, from: nil, to: NIL_UUID

        t.change_null :title, false, ''
        t.change_default :title, from: nil, to: ''
      end
    end

    reversible do |dir|
      dir.up do
        execute "UPDATE app_document_audit_events SET app_document_audit_id = '#{NIL_UUID}' WHERE app_document_audit_id IS NULL"
      end
    end

    change_table :app_document_audit_events, bulk: true do |t|
      t.change_null :app_document_audit_id, false, NIL_UUID
      t.change_default :app_document_audit_id, from: nil, to: NIL_UUID
    end
  end
end
