# frozen_string_literal: true

class AddMissingIdentityForeignKeys < ActiveRecord::Migration[8.2]
  def change
    add_foreign_key :post_versions, :posts,
                    column: :post_id, validate: false

    add_foreign_key :divisions, :divisions,
                    column: :parent_id, validate: false
  end
end
