# frozen_string_literal: true

class SetAppDocumentStatusIdDefaultToNeyo < ActiveRecord::Migration[7.1]
  def up
    return unless table_exists?(:app_document_statuses)

    insert_status("NEYO")
    delete_status("NONE")

    change_column_default :app_document_statuses, :id, from: "NONE", to: "NEYO"
  end

  def down
    return unless table_exists?(:app_document_statuses)

    insert_status("NONE")
    delete_status("NEYO")

    change_column_default :app_document_statuses, :id, from: "NEYO", to: "NONE"
  end

  private

  def insert_status(id)
    cols = [:id]
    vals = [id]

    if column_exists?(:app_document_statuses, :active)
      cols << :active
      vals << true
    end

    if column_exists?(:app_document_statuses, :position)
      cols << :position
      vals << 0
    end

    if column_exists?(:app_document_statuses, :description)
      cols << :description
      vals << id
    end

    if column_exists?(:app_document_statuses, :created_at)
      cols << :created_at
      vals << Time.current
    end

    if column_exists?(:app_document_statuses, :updated_at)
      cols << :updated_at
      vals << Time.current
    end

    safety_assured do
      execute <<~SQL.squish
        INSERT INTO app_document_statuses (#{cols.join(", ")})
        VALUES (#{vals.map { |v| connection.quote(v) }.join(", ")})
        ON CONFLICT (id) DO NOTHING
      SQL
    end
  end

  def delete_status(id)
    safety_assured do
      execute <<~SQL.squish
        DELETE FROM app_document_statuses
        WHERE id = '#{id}'
      SQL
    end
  end
end
