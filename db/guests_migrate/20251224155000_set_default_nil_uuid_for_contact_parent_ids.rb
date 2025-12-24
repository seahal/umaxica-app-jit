class SetDefaultNilUuidForContactParentIds < ActiveRecord::Migration[8.2]
  NIL_UUID = "00000000-0000-0000-0000-000000000000"

  def change
    tables = %w[app_contact_categories com_contact_statuses org_contact_statuses]

    tables.each do |table|
      reversible do |dir|
        dir.up do
          execute "UPDATE #{table} SET parent_id = '#{NIL_UUID}' WHERE parent_id IS NULL"
        end
      end

      change_table table.to_sym, bulk: true do |t|
        t.change_default :parent_id, from: nil, to: NIL_UUID
      end
    end
  end
end
