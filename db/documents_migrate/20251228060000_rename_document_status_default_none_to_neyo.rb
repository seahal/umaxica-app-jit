# frozen_string_literal: true

class RenameDocumentStatusDefaultNoneToNeyo < ActiveRecord::Migration[7.1]
  def up
    update_status_defaults(from: "NONE", to: "NEYO")
  end

  def down
    update_status_defaults(from: "NEYO", to: "NONE")
  end

  private

  def update_status_defaults(from:, to:)
    %i(app_documents com_documents org_documents).each do |table|
      next unless column_exists?(table, :status_id)

      safety_assured do
        execute <<~SQL.squish
          UPDATE #{table}
          SET status_id = #{connection.quote(to)}
          WHERE status_id = #{connection.quote(from)}
        SQL
      end

      change_column_default table, :status_id, from: from, to: to
    end
  end
end
