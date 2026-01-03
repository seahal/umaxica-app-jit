# frozen_string_literal: true

class SeedIdentityReferenceData < ActiveRecord::Migration[8.2]
  def up
    # UserIdentityStatus
    seed_ids(:user_identity_statuses, %w(NONE ALIVE VERIFIED_WITH_SIGN_UP PRE_WITHDRAWAL_CONDITION WITHDRAWAL_COMPLETED))

    # UserIdentityEmailStatus
    seed_ids(:user_identity_email_statuses, %w(NONE UNVERIFIED_WITH_SIGN_UP VERIFIED_WITH_SIGN_UP ALIVE SUSPENDED DELETED))

    # UserIdentityTelephoneStatus
    seed_ids(:user_identity_telephone_statuses, %w(NONE UNVERIFIED_WITH_SIGN_UP VERIFIED_WITH_SIGN_UP ALIVE SUSPENDED DELETED))

    # StaffIdentityStatus
    seed_ids(:staff_identity_statuses, %w(NONE ALIVE PRE_WITHDRAWAL_CONDITION WITHDRAWAL_COMPLETED))

    # StaffIdentityEmailStatus
    seed_ids(:staff_identity_email_statuses, %w(UNVERIFIED_WITH_SIGN_UP VERIFIED_WITH_SIGN_UP ALIVE SUSPENDED DELETED))

    # StaffIdentityTelephoneStatus
    seed_ids(:staff_identity_telephone_statuses, %w(UNVERIFIED_WITH_SIGN_UP VERIFIED_WITH_SIGN_UP ALIVE SUSPENDED DELETED))

    # UserIdentitySecretStatus
    seed_ids(:user_identity_secret_statuses, %w(ACTIVE SUSPENDED))

    # StaffIdentitySecretStatus
    seed_ids(:staff_identity_secret_statuses, %w(ACTIVE USED REVOKED DELETED))

    # AvatarCapability
    seed_with_attributes(
      :avatar_capabilities, [
        { id: "normal", key: "normal", name: "Normal" },
        { id: "cooldown", key: "cooldown", name: "Cooldown" },
        { id: "restricted", key: "restricted", name: "Restricted" },
        { id: "suspended", key: "suspended", name: "Suspended" },
        { id: "banned", key: "banned", name: "Banned" },
      ],
    )

    # HandleStatus
    seed_with_attributes(
      :handle_statuses, [
        { id: "ACTIVE", key: "ACTIVE", name: "Active" },
      ],
    )

    # HandleAssignmentStatus
    seed_with_attributes(
      :handle_assignment_statuses, [
        { id: "ACTIVE", key: "ACTIVE", name: "Active" },
      ],
    )

    # AvatarMonikerStatus
    seed_with_attributes(
      :avatar_moniker_statuses, [
        { id: "ACTIVE", key: "ACTIVE", name: "Active" },
      ],
    )

    # AvatarMembershipStatus
    seed_with_attributes(
      :avatar_membership_statuses, [
        { id: "ACTIVE", key: "ACTIVE", name: "Active" },
      ],
    )

    # AvatarOwnershipStatus
    seed_with_attributes(
      :avatar_ownership_statuses, [
        { id: "ACTIVE", key: "ACTIVE", name: "Active" },
      ],
    )

    # PostStatus
    seed_with_attributes(
      :post_statuses, [
        { id: "DRAFT", key: "DRAFT", name: "Draft" },
      ],
    )

    # PostReviewStatus
    seed_with_attributes(
      :post_review_statuses, [
        { id: "PENDING", key: "PENDING", name: "Pending" },
      ],
    )
  end

  def down
    # No-op to avoid removing shared reference data
  end

  private

  def seed_ids(table_name, ids)
    return unless table_exists?(table_name)

    has_timestamps = column_exists?(table_name, :created_at)

    ids.each do |_id|
      if has_timestamps
      else
      end
    end
  end

  def seed_with_attributes(table_name, records)
    return unless table_exists?(table_name)

    has_timestamps = column_exists?(table_name, :created_at)

    records.each do |record|
      # Filter out columns that don't exist in the table
      existing_columns = record.keys.select { |col| column_exists?(table_name, col) }
      columns = existing_columns
      values = existing_columns.map { |col| "'#{record[col].to_s.gsub("'", "''")}'" }

      if has_timestamps
        columns += [:created_at, :updated_at]
        values += ['CURRENT_TIMESTAMP', 'CURRENT_TIMESTAMP']
      end

      # Determine conflict column - use id if it exists in both record and table, otherwise skip
      conflict_col = (record.key?(:id) && column_exists?(table_name, :id)) ? "id" : nil
      next unless conflict_col
    end
  end
end
