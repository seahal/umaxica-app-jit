# frozen_string_literal: true

# == Schema Information
#
# Table name: app_document_audit_levels
# Database name: activity
#
#  id :bigint           not null, primary key
#

class AppDocumentAuditLevel < ActivityRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  NEYO = 1

  has_many :app_document_audits, dependent: :restrict_with_error, inverse_of: :app_document_audit_level
end
