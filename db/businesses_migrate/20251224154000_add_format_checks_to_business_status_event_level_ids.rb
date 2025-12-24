require "digest"

class AddFormatChecksToBusinessStatusEventLevelIds < ActiveRecord::Migration[8.2]
  FORMAT_REGEX = "^[A-Z0-9_]+$"

  def change
    add_format_check :app_document_statuses, :id
    add_format_check :com_document_statuses, :id
    add_format_check :org_document_statuses, :id

    add_format_check :app_document_audit_events, :id
    add_format_check :com_document_audit_events, :id
    add_format_check :org_document_audit_events, :id

    add_format_check :app_document_audit_levels, :id
    add_format_check :com_document_audit_levels, :id
    add_format_check :org_document_audit_levels, :id

    add_format_check :app_timeline_statuses, :id
    add_format_check :com_timeline_statuses, :id
    add_format_check :org_timeline_statuses, :id

    add_format_check :app_timeline_audit_events, :id
    add_format_check :com_timeline_audit_events, :id
    add_format_check :org_timeline_audit_events, :id

    add_format_check :app_timeline_audit_levels, :id
    add_format_check :com_timeline_audit_levels, :id
    add_format_check :org_timeline_audit_levels, :id
  end

  private

    def add_format_check(table, column)
      add_check_constraint(
        table,
        "#{column} IS NULL OR #{column} ~ '#{FORMAT_REGEX}'",
        name: constraint_name(table, column)
      )
    end

    def constraint_name(table, column)
      base = "chk_#{table}_#{column}_format"
      return base if base.length <= 63

      digest = Digest::SHA256.hexdigest(base)[0, 10]
      "chk_#{table}_#{column}_#{digest}"
    end
end
