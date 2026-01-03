# frozen_string_literal: true

class EnsureOccurrenceStatuses < ActiveRecord::Migration[8.2]
  STATUS_IDS = %w(NEYO ACTIVE INACTIVE BLOCKED).freeze
  TABLES = %w(
    area_occurrence_statuses
    domain_occurrence_statuses
    email_occurrence_statuses
    ip_occurrence_statuses
    telephone_occurrence_statuses
    zip_occurrence_statuses
    staff_occurrence_statuses
    user_occurrence_statuses
  ).freeze

  def up
    # No-op: data seeding moved to fixtures.
  end

  def down
    # No-op: data seeding moved to fixtures.
  end
end
