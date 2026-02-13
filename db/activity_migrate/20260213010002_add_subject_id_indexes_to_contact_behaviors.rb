# frozen_string_literal: true

class AddSubjectIdIndexesToContactBehaviors < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  INDEXES = {
    app_contact_behaviors: "index_app_contact_behaviors_on_subject_id",
    com_contact_behaviors: "index_com_contact_behaviors_on_subject_id",
    org_contact_behaviors: "index_org_contact_behaviors_on_subject_id",
  }.freeze

  def up
    safety_assured do
      INDEXES.each do |table, index_name|
        next unless table_exists?(table)

        add_index table, :subject_id, name: index_name, algorithm: :concurrently, if_not_exists: true
      end
    end
  end

  def down
    safety_assured do
      INDEXES.each do |table, index_name|
        next unless table_exists?(table)

        remove_index table, name: index_name, algorithm: :concurrently, if_exists: true
      end
    end
  end
end
