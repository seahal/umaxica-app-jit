# frozen_string_literal: true

class RemoveRedundantOccurrenceStatusIndexes < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  USER_INDEX = "index_user_occurrences_on_status_id"
  STAFF_INDEX = "index_staff_occurrences_on_status_id"

  def up
    safety_assured do
      remove_index(:user_occurrences, name: USER_INDEX, algorithm: :concurrently) if index_exists?(
        :user_occurrences,
        :status_id, name: USER_INDEX,
      )
      remove_index(
        :staff_occurrences, name: STAFF_INDEX,
                            algorithm: :concurrently,
      ) if index_exists?(
        :staff_occurrences,
        :status_id, name: STAFF_INDEX,
      )
    end
  end

  def down
    add_index(:user_occurrences, :status_id, name: USER_INDEX, algorithm: :concurrently) unless index_exists?(
      :user_occurrences, :status_id, name: USER_INDEX,
    )
    add_index(:staff_occurrences, :status_id, name: STAFF_INDEX, algorithm: :concurrently) unless index_exists?(
      :staff_occurrences, :status_id, name: STAFF_INDEX,
    )
  end
end
