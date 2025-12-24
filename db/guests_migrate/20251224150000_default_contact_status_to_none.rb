class DefaultContactStatusToNone < ActiveRecord::Migration[8.2]
  CONTACT_TABLES = %w[app_contacts com_contacts org_contacts].freeze

  def change
    CONTACT_TABLES.each do |table|
      reversible do |dir|
        dir.up do
          execute <<~SQL.squish
            UPDATE #{table}
            SET contact_status_id = 'NONE'
            WHERE contact_status_id = ''
          SQL
        end
      end

      change_table table.to_sym, bulk: true do |t|
        t.change_default :contact_status_id, from: "", to: "NONE"
      end
    end
  end
end
