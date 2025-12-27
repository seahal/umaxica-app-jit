# frozen_string_literal: true

class SetDefaultNoneOnOccurrenceStatusIds < ActiveRecord::Migration[8.2]
  TABLES = %i(
    area_occurrences
    domain_occurrences
    email_occurrences
    ip_occurrences
    staff_occurrences
    telephone_occurrences
    user_occurrences
    zip_occurrences
  ).freeze

  def change
    TABLES.each do |table|
      reversible do |dir|
        dir.up do
          execute "UPDATE #{table} SET status_id = 'NONE' WHERE status_id IS NULL OR status_id = ''"
        end
      end

      change_table table, bulk: true do |t|
        t.change_default :status_id, from: "", to: "NONE"
        t.change_null :status_id, false, "NONE"
      end
    end
  end
end
