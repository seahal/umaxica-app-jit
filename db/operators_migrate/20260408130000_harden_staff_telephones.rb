# frozen_string_literal: true

# Hardens staff_telephones to match the schema conventions used by user_telephones
# and customer_telephones:
#
#   - Adds number_bidx / number_digest for blind-index lookup (avoids full-table decrypt)
#   - Adds public_id for URL-safe identification (avoids sequential integer IDs in URLs)
#   - Adds otp_last_sent_at for OTP cooldown tracking
#   - Sets NOT NULL + default(-Infinity) on locked_at and otp_expires_at
#   - Sets NOT NULL + default("") on number
#
class HardenStaffTelephones < ActiveRecord::Migration[8.0]
  # This migration mixes DDL and a data backfill; running without a wrapping
  # transaction avoids idle-in-transaction timeouts during the backfill loop.
  disable_ddl_transaction!

  def up
    # Step 1: add nullable columns first so existing rows are valid during migration.
    add_column :staff_telephones, :number_bidx,      :string,   if_not_exists: true
    add_column :staff_telephones, :number_digest,    :string,   if_not_exists: true
    add_column :staff_telephones, :public_id,        :string,   limit: 21, if_not_exists: true
    add_column :staff_telephones, :otp_last_sent_at, :datetime, if_not_exists: true

    # Step 2: fix nullable columns that should have been not-null from the start.
    # Convert existing NULLs to the sentinel value, then tighten the constraint.
    safety_assured do
      execute <<~SQL
        UPDATE staff_telephones SET locked_at = '-infinity'::timestamp WHERE locked_at IS NULL;
      SQL
      execute <<~SQL
        UPDATE staff_telephones SET otp_expires_at = '-infinity'::timestamp WHERE otp_expires_at IS NULL;
      SQL
      execute <<~SQL
        UPDATE staff_telephones SET number = '' WHERE number IS NULL;
      SQL
      execute <<~SQL
        UPDATE staff_telephones SET otp_last_sent_at = '-infinity'::timestamp;
      SQL
    end

    change_column_default :staff_telephones, :locked_at,       "-infinity"
    change_column_default :staff_telephones, :otp_expires_at,  "-infinity"
    change_column_default :staff_telephones, :number,          ""
    change_column_default :staff_telephones, :otp_last_sent_at, "-infinity"

    # All rows have been backfilled above — safe to set NOT NULL without a table scan risk.
    safety_assured do
      change_column_null :staff_telephones, :locked_at,       false
      change_column_null :staff_telephones, :otp_expires_at,  false
      change_column_null :staff_telephones, :number,          false
      change_column_null :staff_telephones, :otp_last_sent_at, false
    end

    # Step 3: backfill public_id using Nanoid (same size as UserTelephone / CustomerTelephone).
    say_with_time("Backfilling staff_telephones.public_id") do
      StaffTelephone.find_each do |record|
        record.update_column(:public_id, Nanoid.generate(size: 21))
      end
    end

    # Step 4: backfill number_bidx / number_digest from the decrypted number.
    say_with_time("Backfilling staff_telephones.number_bidx / number_digest") do
      StaffTelephone.find_each do |record|
        bidx = IdentifierBlindIndex.bidx_for_telephone(record.number)
        next if bidx.blank?

        record.update_columns(number_bidx: bidx, number_digest: bidx)
      end
    end

    # Step 5: add constraints and indexes after data is clean.
    # All public_id values were just backfilled above — safe to set NOT NULL.
    safety_assured { change_column_null :staff_telephones, :public_id, false }

    add_index :staff_telephones, :public_id, unique: true, if_not_exists: true, algorithm: :concurrently
    add_index :staff_telephones, :number_bidx,
              unique: true,
              where: "(number_bidx IS NOT NULL)",
              name:  "index_staff_telephones_on_number_bidx",
              if_not_exists: true,
              algorithm: :concurrently
    add_index :staff_telephones, :number_digest,
              unique: true,
              where: "(number_digest IS NOT NULL)",
              name:  "index_staff_telephones_on_number_digest",
              if_not_exists: true,
              algorithm: :concurrently
  end

  def down
    remove_index :staff_telephones, :public_id, if_exists: true
    remove_index :staff_telephones, name: "index_staff_telephones_on_number_bidx", if_exists: true
    remove_index :staff_telephones, name: "index_staff_telephones_on_number_digest", if_exists: true

    remove_column :staff_telephones, :number_bidx,       if_exists: true
    remove_column :staff_telephones, :number_digest,     if_exists: true
    remove_column :staff_telephones, :public_id,         if_exists: true
    remove_column :staff_telephones, :otp_last_sent_at,  if_exists: true

    change_column_default :staff_telephones, :locked_at,      nil
    change_column_default :staff_telephones, :otp_expires_at, nil
    change_column_default :staff_telephones, :number,         nil

    change_column_null :staff_telephones, :locked_at,      true
    change_column_null :staff_telephones, :otp_expires_at, true
    change_column_null :staff_telephones, :number,         false
  end
end
