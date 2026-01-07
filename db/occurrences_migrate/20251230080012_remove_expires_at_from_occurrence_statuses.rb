# frozen_string_literal: true

class RemoveExpiresAtFromOccurrenceStatuses < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      remove_column :area_occurrence_statuses, :expires_at, :timestamptz
      remove_column :domain_occurrence_statuses, :expires_at, :timestamptz
      remove_column :email_occurrence_statuses, :expires_at, :timestamptz
      remove_column :ip_occurrence_statuses, :expires_at, :timestamptz
      remove_column :telephone_occurrence_statuses, :expires_at, :timestamptz
      remove_column :zip_occurrence_statuses, :expires_at, :timestamptz
      remove_column :staff_occurrence_statuses, :expires_at, :timestamptz
      remove_column :user_occurrence_statuses, :expires_at, :timestamptz
    end
  end
end
