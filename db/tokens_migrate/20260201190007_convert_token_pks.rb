# frozen_string_literal: true

class ConvertTokenPks < ActiveRecord::Migration[8.0]
  def up
    safety_assured do
    # -------------------------------------------------------------------------
    # DEPENDENTS (Drop first)
    # -------------------------------------------------------------------------
    # None explicit in schema other than indexes, but let's check for FKs.
    # staff_tokens and user_tokens are valid tables.

    drop_table(:reauth_sessions, if_exists: true)
    drop_table(:staff_tokens, if_exists: true)
    drop_table(:user_tokens, if_exists: true)

    # Drop Lookups
    drop_table(:staff_token_kinds, if_exists: true)
    drop_table(:staff_token_statuses, if_exists: true)
    drop_table(:user_token_kinds, if_exists: true)
    drop_table(:user_token_statuses, if_exists: true)

    # -------------------------------------------------------------------------
    # RECREATE TABLES (Bigint PK)
    # -------------------------------------------------------------------------

    # 1. Reauth Sessions
    create_table(:reauth_sessions) do |t|
      t.bigint("actor_id", null: false) # Changed uuid -> bigint
      t.string("actor_type", null: false)
      t.integer("attempt_count", default: 0, null: false)
      t.datetime("created_at", null: false)
      t.datetime("expires_at", null: false)
      t.string("method", null: false)
      t.text("return_to", null: false)
      t.string("scope", null: false)
      t.string("status", null: false)
      t.datetime("updated_at", null: false)
      t.datetime("verified_at")
      t.index(%w(actor_type actor_id status), name: "index_reauth_sessions_on_actor_type_and_actor_id_and_status")
      t.index(["expires_at"], name: "index_reauth_sessions_on_expires_at")
    end

    # 2. Staff Token Lookups

    create_table(:staff_token_kinds, id: { type: :integer, limit: 2, default: nil })

    create_table(:staff_token_statuses, id: { type: :integer, limit: 2, default: nil }) do |t|
      t.check_constraint("id >= 0", name: "chk_staff_token_statuses_id_positive")
    end

    # 3. Staff Tokens
    create_table(:staff_tokens) do |t|
      t.datetime("compromised_at")
      t.datetime("created_at", null: false)
      t.datetime("last_step_up_at")
      t.string("last_step_up_scope")
      t.datetime("last_used_at")
      t.string("public_id", limit: 21, default: "", null: false)
      t.datetime("refresh_expires_at", null: false)
      t.binary("refresh_token_digest")
      t.string("refresh_token_family_id")
      t.integer("refresh_token_generation", default: 0, null: false)
      t.datetime("revoked_at")
      t.datetime("rotated_at")
      t.bigint("staff_id", null: false) # Changed from uuid to bigint
      t.integer("staff_token_kind_id", limit: 2, default: 1, null: false)
      t.integer("staff_token_status_id", limit: 2, default: 0, null: false)
      t.datetime("updated_at", null: false)
      t.index(["compromised_at"], name: "index_staff_tokens_on_compromised_at")
      t.index(["public_id"], name: "index_staff_tokens_on_public_id", unique: true)
      t.index(["refresh_expires_at"], name: "index_staff_tokens_on_refresh_expires_at")
      t.index(["refresh_token_digest"], name: "index_staff_tokens_on_refresh_token_digest", unique: true)
      t.index(["refresh_token_family_id"], name: "index_staff_tokens_on_refresh_token_family_id")
      t.index(["revoked_at"], name: "index_staff_tokens_on_revoked_at")
      t.index(["staff_id", "last_step_up_at"], name: "index_staff_tokens_on_staff_id_and_last_step_up_at")
      t.index(["staff_id"], name: "index_staff_tokens_on_staff_id")
      t.index(["staff_token_kind_id"], name: "index_staff_tokens_on_staff_token_kind_id")
      t.index(["staff_token_status_id"], name: "index_staff_tokens_on_staff_token_status_id")
      t.check_constraint("staff_token_kind_id >= 0", name: "chk_staff_tokens_kind_id_positive")
      t.check_constraint("staff_token_status_id >= 0", name: "chk_staff_tokens_status_id_positive")
    end

    # 4. User Token Lookups

    create_table(:user_token_kinds, id: { type: :integer, limit: 2, default: nil })

    create_table(:user_token_statuses, id: { type: :integer, limit: 2, default: nil }) do |t|
      t.check_constraint("id >= 0", name: "chk_user_token_statuses_id_positive")
    end

    # 5. User Tokens
    create_table(:user_tokens) do |t|
      t.datetime("compromised_at")
      t.datetime("created_at", null: false)
      t.datetime("last_step_up_at")
      t.string("last_step_up_scope")
      t.datetime("last_used_at")
      t.string("public_id", limit: 21, default: "", null: false)
      t.datetime("refresh_expires_at", null: false)
      t.binary("refresh_token_digest")
      t.string("refresh_token_family_id")
      t.integer("refresh_token_generation", default: 0, null: false)
      t.datetime("revoked_at")
      t.datetime("rotated_at")
      t.datetime("updated_at", null: false)
      t.bigint("user_id", null: false) # Changed from uuid to bigint
      t.integer("user_token_kind_id", limit: 2, default: 1, null: false)
      t.integer("user_token_status_id", limit: 2, default: 0, null: false)
      t.index(["compromised_at"], name: "index_user_tokens_on_compromised_at")
      t.index(["public_id"], name: "index_user_tokens_on_public_id", unique: true)
      t.index(["refresh_expires_at"], name: "index_user_tokens_on_refresh_expires_at")
      t.index(["refresh_token_digest"], name: "index_user_tokens_on_refresh_token_digest", unique: true)
      t.index(["refresh_token_family_id"], name: "index_user_tokens_on_refresh_token_family_id")
      t.index(["revoked_at"], name: "index_user_tokens_on_revoked_at")
      t.index(["user_id", "last_step_up_at"], name: "index_user_tokens_on_user_id_and_last_step_up_at")
      t.index(["user_id"], name: "index_user_tokens_on_user_id")
      t.index(["user_token_kind_id"], name: "index_user_tokens_on_user_token_kind_id")
      t.index(["user_token_status_id"], name: "index_user_tokens_on_user_token_status_id")
      t.check_constraint("user_token_kind_id >= 0", name: "chk_user_tokens_kind_id_positive")
      t.check_constraint("user_token_status_id >= 0", name: "chk_user_tokens_status_id_positive")
    end

    add_foreign_key("staff_tokens", "staff_token_kinds", validate: false)
    add_foreign_key("staff_tokens", "staff_token_statuses", validate: false)
    add_foreign_key("user_tokens", "user_token_kinds", validate: false)
    add_foreign_key("user_tokens", "user_token_statuses", validate: false)
  end

    end
  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
