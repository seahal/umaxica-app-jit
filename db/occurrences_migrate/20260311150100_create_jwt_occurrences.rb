# frozen_string_literal: true

class CreateJwtOccurrences < ActiveRecord::Migration[8.2]
  def change
    create_table(:jwt_occurrences) do |t|
      t.string(:body, null: false, default: "")
      t.string(:memo, null: false, default: "")
      t.string(:public_id, null: false, default: "", limit: 21)
      t.bigint(:status_id, null: false, default: 1)
      t.timestamptz(:expires_at, null: false, default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" })
      t.timestamps
    end

    add_index(:jwt_occurrences, :body, unique: true)
    add_index(:jwt_occurrences, %i(body created_at))
    add_index(:jwt_occurrences, :expires_at)
    add_index(:jwt_occurrences, :public_id, unique: true)
    add_index(:jwt_occurrences, :status_id)
    add_foreign_key(
      :jwt_occurrences, :jwt_occurrence_statuses,
      column: :status_id,
      name: "fk_jwt_occurrences_on_status_id",
      validate: false,
    )

    add_check_constraint(:jwt_occurrences, "char_length(memo) <= 1000", name: "chk_jwt_occurrences_memo_length")
  end
end
