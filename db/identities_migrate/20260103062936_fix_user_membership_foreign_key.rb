# frozen_string_literal: true

class FixUserMembershipForeignKey < ActiveRecord::Migration[8.2]
  def change
    remove_foreign_key :user_memberships, :departments, column: :workspace_id
    add_foreign_key :user_memberships, :workspaces, column: :workspace_id, validate: false
  end
end
