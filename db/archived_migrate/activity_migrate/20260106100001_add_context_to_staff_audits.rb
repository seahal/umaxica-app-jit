# frozen_string_literal: true

class AddContextToStaffAudits < ActiveRecord::Migration[8.2]
  def change
    add_column(:staff_audits, :context, :jsonb, default: {}, null: false) unless column_exists?(:staff_audits, :context)
  end
end
