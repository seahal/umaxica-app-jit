# typed: false
# frozen_string_literal: true

class AddMissingAvatarForeignKeys < ActiveRecord::Migration[8.2]
  def change
    add_foreign_key(
      :post_versions, :posts,
      column: :post_id, validate: false,
    )
  end
end
