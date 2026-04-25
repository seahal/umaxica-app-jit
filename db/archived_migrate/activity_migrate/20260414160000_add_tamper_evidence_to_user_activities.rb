# typed: false
# frozen_string_literal: true

class AddTamperEvidenceToUserActivities < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    # Add sequence number for gap detection
    add_column :user_activities, :sequence_number, :bigint
    add_index :user_activities, :sequence_number, unique: true, algorithm: :concurrently

    # Add digest for chain validation (contains hash of previous record + current data)
    add_column :user_activities, :previous_digest, :string
    add_column :user_activities, :record_digest, :string
    add_index :user_activities, :record_digest, unique: true, algorithm: :concurrently

    # Add TSA (Timestamp Authority) fields for external timestamp attestation
    add_column :user_activities, :tsa_token, :text
    add_column :user_activities, :tsa_at, :datetime
    add_index :user_activities, :tsa_at, algorithm: :concurrently

    # Add chain validation index (for quick chain integrity checks)
    add_index :user_activities, [:sequence_number, :record_digest],
              name: "index_user_activities_on_chain_validation",
              algorithm: :concurrently
  end
end
