# typed: false
# frozen_string_literal: true

class AuditRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :audit, reading: :audit_replica }
end
