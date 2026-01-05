# frozen_string_literal: true

class RemoveDescriptionFromIdentityStatuses < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      remove_column :avatar_membership_statuses, :description, :text
      remove_column :avatar_moniker_statuses, :description, :text
      remove_column :avatar_ownership_statuses, :description, :text
      remove_column :handle_assignment_statuses, :description, :text
      remove_column :handle_statuses, :description, :text
      remove_column :post_review_statuses, :description, :text
      remove_column :post_statuses, :description, :text
    end
  end
end
