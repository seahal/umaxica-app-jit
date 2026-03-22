# frozen_string_literal: true

class AddBodyCreatedAtIndexesToOccurrences < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    add_index(
      :email_occurrences, [:body, :created_at],
      name: "index_email_occurrences_on_body_created_at",
      algorithm: :concurrently,
      if_not_exists: true,
    )
    add_index(
      :telephone_occurrences, [:body, :created_at],
      name: "index_telephone_occurrences_on_body_created_at",
      algorithm: :concurrently,
      if_not_exists: true,
    )
    add_index(
      :ip_occurrences, [:body, :created_at],
      name: "index_ip_occurrences_on_body_created_at",
      algorithm: :concurrently,
      if_not_exists: true,
    )
  end
end
