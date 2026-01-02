# frozen_string_literal: true

class AddUniqueIndexesForCaseInsensitiveLookups < ActiveRecord::Migration[8.2]
  def change
    # Timeline tag masters
    add_index :org_timeline_tag_masters, "lower(id)", unique: true, name: "index_org_timeline_tag_masters_on_lower_id"
    add_index :com_timeline_tag_masters, "lower(id)", unique: true, name: "index_com_timeline_tag_masters_on_lower_id"
    add_index :app_timeline_tag_masters, "lower(id)", unique: true, name: "index_app_timeline_tag_masters_on_lower_id"

    # Timeline category masters
    add_index :org_timeline_category_masters, "lower(id)", unique: true,
                                                           name: "index_org_timeline_category_masters_on_lower_id"
    add_index :com_timeline_category_masters, "lower(id)", unique: true,
                                                           name: "index_com_timeline_category_masters_on_lower_id"
    add_index :app_timeline_category_masters, "lower(id)", unique: true,
                                                           name: "index_app_timeline_category_masters_on_lower_id"

    # Document tag masters
    add_index :org_document_tag_masters, "lower(id)", unique: true, name: "index_org_document_tag_masters_on_lower_id"
    add_index :com_document_tag_masters, "lower(id)", unique: true, name: "index_com_document_tag_masters_on_lower_id"
    add_index :app_document_tag_masters, "lower(id)", unique: true, name: "index_app_document_tag_masters_on_lower_id"

    # Document category masters
    add_index :org_document_category_masters, "lower(id)", unique: true,
                                                           name: "index_org_document_category_masters_on_lower_id"
    add_index :com_document_category_masters, "lower(id)", unique: true,
                                                           name: "index_com_document_category_masters_on_lower_id"
    add_index :app_document_category_masters, "lower(id)", unique: true,
                                                           name: "index_app_document_category_masters_on_lower_id"

    # Status tables
    add_index :division_statuses, "lower(id)", unique: true, name: "index_division_statuses_on_lower_id"
    add_index :department_statuses, "lower(id)", unique: true, name: "index_department_statuses_on_lower_id"
    add_index :client_identity_statuses, "lower(id)", unique: true, name: "index_client_identity_statuses_on_lower_id"
    add_index :admin_identity_statuses, "lower(id)", unique: true, name: "index_admin_identity_statuses_on_lower_id"
  end
end
