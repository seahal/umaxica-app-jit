class AddUniversalIndexesAndFks < ActiveRecord::Migration[8.2]
  def change
    # Timeline/Document Audits Indexes - Removed invalid user_id indexes

    # User/Staff Audit Indexes
    # User/Staff Audit Indexes - Removed invalid user_id/staff_id indexes

    # Lower ID Unique Indexes for Status Tables
    add_index :zip_occurrence_statuses, "lower(id)", unique: true, name: "index_zip_occurrence_statuses_on_lower_id", if_not_exists: true
    add_index :user_occurrence_statuses, "lower(id)", unique: true, name: "index_user_occurrence_statuses_on_lower_id", if_not_exists: true
    add_index :telephone_occurrence_statuses, "lower(id)", unique: true, name: "index_telephone_occurrence_statuses_on_lower_id", if_not_exists: true
    add_index :staff_occurrence_statuses, "lower(id)", unique: true, name: "index_staff_occurrence_statuses_on_lower_id", if_not_exists: true
    add_index :ip_occurrence_statuses, "lower(id)", unique: true, name: "index_ip_occurrence_statuses_on_lower_id", if_not_exists: true
    add_index :email_occurrence_statuses, "lower(id)", unique: true, name: "index_email_occurrence_statuses_on_lower_id", if_not_exists: true
    add_index :domain_occurrence_statuses, "lower(id)", unique: true, name: "index_domain_occurrence_statuses_on_lower_id", if_not_exists: true
    add_index :area_occurrence_statuses, "lower(id)", unique: true, name: "index_area_occurrence_statuses_on_lower_id", if_not_exists: true

    # Occurrence Foreign Keys
    add_foreign_key :zip_occurrences, :zip_occurrence_statuses, column: :status_id, if_not_exists: true
    add_foreign_key :user_occurrences, :user_occurrence_statuses, column: :status_id, if_not_exists: true
    add_foreign_key :telephone_occurrences, :telephone_occurrence_statuses, column: :status_id, if_not_exists: true
    add_foreign_key :staff_occurrences, :staff_occurrence_statuses, column: :status_id, if_not_exists: true
    add_foreign_key :ip_occurrences, :ip_occurrence_statuses, column: :status_id, if_not_exists: true
    add_foreign_key :email_occurrences, :email_occurrence_statuses, column: :status_id, if_not_exists: true
    add_foreign_key :domain_occurrences, :domain_occurrence_statuses, column: :status_id, if_not_exists: true
    add_foreign_key :area_occurrences, :area_occurrence_statuses, column: :status_id, if_not_exists: true
  end
end
