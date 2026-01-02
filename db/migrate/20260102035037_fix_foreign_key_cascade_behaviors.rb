# frozen_string_literal: true

class FixForeignKeyCascadeBehaviors < ActiveRecord::Migration[8.2]
  def change
    # Add foreign keys with restrict behavior for contact categories
    add_foreign_key :org_contacts, :org_contact_categories,
                    column: :category_id,
                    primary_key: :id,
                    on_delete: :restrict

    add_foreign_key :com_contacts, :com_contact_categories,
                    column: :category_id,
                    primary_key: :id,
                    on_delete: :restrict

    add_foreign_key :app_contacts, :app_contact_categories,
                    column: :category_id,
                    primary_key: :id,
                    on_delete: :restrict

    # Add foreign key with nullify behavior for user's owned_clients
    add_foreign_key :clients, :users,
                    column: :user_id,
                    on_delete: :nullify

    # Add foreign key with nullify behavior for client's avatars
    add_foreign_key :client_avatars, :clients,
                    column: :client_id,
                    on_delete: :nullify
  end
end
