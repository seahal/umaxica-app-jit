# frozen_string_literal: true

class AddNeyoToIdentityStatusTables < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      # Status models using UppercaseId pattern
      %w(
        staff_identity_secret_statuses
        user_identity_secret_statuses
        user_identity_social_apple_statuses
        user_identity_social_google_statuses
      ).each do |table_name|
        # No-op: intentionally left blank.
      end

      # Status models using StringPrimaryKey pattern (key/name structure)
      %w(
        avatar_membership_statuses
        avatar_moniker_statuses
        avatar_ownership_statuses
        handle_statuses
        handle_assignment_statuses
        post_statuses
        post_review_statuses
      ).each do |table_name|
        # Check if key and name columns exist (they may have been removed by later migrations)
        has_key = column_exists?(table_name.to_sym, :key)
        has_name = column_exists?(table_name.to_sym, :name)

        if has_key && has_name
        else
        end
      end
    end
  end

  def down
    safety_assured do
      %w(
        staff_identity_secret_statuses
        user_identity_secret_statuses
        user_identity_social_apple_statuses
        user_identity_social_google_statuses
        avatar_membership_statuses
        avatar_moniker_statuses
        avatar_ownership_statuses
        handle_statuses
        handle_assignment_statuses
        post_statuses
        post_review_statuses
      ).each do |table_name|
        # No-op: intentionally left blank.
      end
    end
  end
end
