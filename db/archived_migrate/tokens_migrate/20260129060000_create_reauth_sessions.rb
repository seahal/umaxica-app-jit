# frozen_string_literal: true

class CreateReauthSessions < ActiveRecord::Migration[8.2]
  def change
    create_table(:reauth_sessions, if_not_exists: true) do |t|
      t.string(:actor_type, null: false)
      t.bigint(:actor_id, null: false)
      t.string(:scope, null: false)
      t.text(:return_to, null: false)
      t.string(:method, null: false)
      t.string(:status, null: false)
      t.datetime(:expires_at, null: false)
      t.datetime(:verified_at)
      t.integer(:attempt_count, null: false, default: 0)

      t.timestamps
    end

    add_index(:reauth_sessions, %i(actor_type actor_id status), if_not_exists: true)
    add_index(:reauth_sessions, :expires_at, if_not_exists: true)
  end
end
