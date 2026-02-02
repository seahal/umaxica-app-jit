# frozen_string_literal: true

class AddMissingUniqueIndexesGuest < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      %w(org_contacts com_contacts app_contacts org_contact_topics com_contact_topics app_contact_topics).each do |table|
        unless index_exists?(table, :public_id, unique: true)
          remove_index table, :public_id if index_exists?(table, :public_id)
          add_index table, :public_id, unique: true, algorithm: :concurrently
        end
      end
    end
  end

  def down
  end
end
