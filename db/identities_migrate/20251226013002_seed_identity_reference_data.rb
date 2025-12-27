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
    seed_with_attributes(:avatar_capabilities, [
      { id: "normal", key: "normal", name: "Normal" },
      { id: "cooldown", key: "cooldown", name: "Cooldown" },
      { id: "restricted", key: "restricted", name: "Restricted" },
      { id: "suspended", key: "suspended", name: "Suspended" },
      { id: "banned", key: "banned", name: "Banned" },
    ],)

    # HandleStatus
    seed_with_attributes(:handle_statuses, [
      { id: "ACTIVE", key: "ACTIVE", name: "Active" },
    ],)

    # HandleAssignmentStatus
    seed_with_attributes(:handle_assignment_statuses, [
      { id: "ACTIVE", key: "ACTIVE", name: "Active" },
    ],)

    # AvatarMonikerStatus
    seed_with_attributes(:avatar_moniker_statuses, [
      { id: "ACTIVE", key: "ACTIVE", name: "Active" },
    ],)

    # AvatarMembershipStatus
    seed_with_attributes(:avatar_membership_statuses, [
      { id: "ACTIVE", key: "ACTIVE", name: "Active" },
    ],)

    # AvatarOwnershipStatus
    seed_with_attributes(:avatar_ownership_statuses, [
      { id: "ACTIVE", key: "ACTIVE", name: "Active" },
    ],)

    # PostStatus
    seed_with_attributes(:post_statuses, [
      { id: "DRAFT", key: "DRAFT", name: "Draft" },
    ],)

    # PostReviewStatus
    seed_with_attributes(:post_review_statuses, [
      { id: "PENDING", key: "PENDING", name: "Pending" },
    ],)
  end

  def down
    # No-op to avoid removing shared reference data
  end

  private

  def seed_ids(table_name, ids)
    return unless table_exists?(table_name)

    has_timestamps = column_exists?(table_name, :created_at)

    ids.each do |id|
      if has_timestamps
        execute <<~SQL.squish
          INSERT INTO #{table_name} (id, created_at, updated_at)
          VALUES ('#{id}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
          ON CONFLICT (id) DO NOTHING
        SQL
      else
        execute <<~SQL.squish
          INSERT INTO #{table_name} (id)
          VALUES ('#{id}')
          ON CONFLICT (id) DO NOTHING
        SQL
      end
    end
  end

  def seed_with_attributes(table_name, records)
    return unless table_exists?(table_name)

    has_timestamps = column_exists?(table_name, :created_at)

    records.each do |record|
      columns = record.keys
      values = record.values.map { |v| "'#{v.to_s.gsub("'", "''")}'" }

      if has_timestamps
        columns += [:created_at, :updated_at]
        values += ['CURRENT_TIMESTAMP', 'CURRENT_TIMESTAMP']
      end

      execute <<~SQL.squish
        INSERT INTO #{table_name} (#{columns.join(", ")})
        VALUES (#{values.join(", ")})
        ON CONFLICT (#{record.key?(:id) ? "id" : "key"}) DO NOTHING
      SQL
    end
  end
end
