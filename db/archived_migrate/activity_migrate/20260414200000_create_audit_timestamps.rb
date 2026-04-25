# typed: false
# frozen_string_literal: true

class CreateAuditTimestamps < ActiveRecord::Migration[8.2]
  def change
    create_table :audit_timestamps, id: :uuid do |t|
      # Polymorphic reference to audit records (UserActivity, StaffActivity, etc.)
      t.string :audit_record_type, null: false
      t.bigint :audit_record_id, null: false

      # TSA Request/Response data
      t.binary :tsa_request, null: false
      t.binary :tsa_response, null: false

      # RFC 3161 Timestamp Token (the actual token returned by TSA)
      t.binary :tsa_token, null: false

      # TSA-issued serial number for this timestamp
      t.string :serial_number, null: false

      # The timestamp issued by TSA (may differ from local time)
      t.datetime :issued_at, null: false

      # Status of the timestamp request (granted, rejected, etc.)
      t.integer :status_id, null: false, default: 0

      # Error code if the request was rejected
      t.integer :error_code

      # Hash algorithm used for the timestamp
      t.string :hash_algorithm, null: false, default: "SHA256"

      # Policy OID used for this timestamp
      t.string :policy_oid

      # Nonce used in the request (to prevent replay attacks)
      t.binary :nonce

      # TSA certificate info (for verification)
      t.binary :tsa_certificate

      # Verification status (whether we've verified this timestamp)
      t.datetime :verified_at
      t.boolean :verification_status

      t.timestamps
    end

    # Indexes for efficient lookup
    add_index :audit_timestamps, [:audit_record_type, :audit_record_id],
              unique: true,
              name: "index_audit_timestamps_on_audit_record"

    add_index :audit_timestamps, :serial_number, unique: true

    add_index :audit_timestamps, :issued_at

    add_index :audit_timestamps, :status_id

    add_index :audit_timestamps, [:audit_record_type, :audit_record_id, :status_id],
              name: "index_audit_timestamps_on_record_and_status"

    add_index :audit_timestamps, :verification_status,
              where: "verification_status IS NOT NULL",
              name: "index_audit_timestamps_on_verification_status"
  end
end
