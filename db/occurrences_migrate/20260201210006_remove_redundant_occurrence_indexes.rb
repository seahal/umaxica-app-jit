# frozen_string_literal: true

# Migration to remove redundant indexes from occurrence tables
# This resolves RedundantIndexChecker warnings
class RemoveRedundantOccurrenceIndexes < ActiveRecord::Migration[7.1]
  def change
    # User occurrences
    remove_index(
      :user_zip_occurrences,
      column: :user_occurrence_id,
      name: "index_user_zip_occurrences_on_user_occurrence_id",
      if_exists: true,
    )

    # Telephone occurrences
    remove_index(
      :telephone_zip_occurrences,
      column: :telephone_occurrence_id,
      name: "index_telephone_zip_occurrences_on_telephone_occurrence_id",
      if_exists: true,
    )
    remove_index(
      :telephone_user_occurrences,
      column: :telephone_occurrence_id,
      name: "index_telephone_user_occurrences_on_telephone_occurrence_id",
      if_exists: true,
    )

    # Staff occurrences
    remove_index(
      :staff_zip_occurrences,
      column: :staff_occurrence_id,
      name: "index_staff_zip_occurrences_on_staff_occurrence_id",
      if_exists: true,
    )
    remove_index(
      :staff_user_occurrences,
      column: :staff_occurrence_id,
      name: "index_staff_user_occurrences_on_staff_occurrence_id",
      if_exists: true,
    )
    remove_index(
      :staff_telephone_occurrences,
      column: :staff_occurrence_id,
      name: "index_staff_telephone_occurrences_on_staff_occurrence_id",
      if_exists: true,
    )

    # IP occurrences
    remove_index(
      :ip_zip_occurrences,
      column: :ip_occurrence_id,
      name: "index_ip_zip_occurrences_on_ip_occurrence_id",
      if_exists: true,
    )
    remove_index(
      :ip_user_occurrences,
      column: :ip_occurrence_id,
      name: "index_ip_user_occurrences_on_ip_occurrence_id",
      if_exists: true,
    )
    remove_index(
      :ip_telephone_occurrences,
      column: :ip_occurrence_id,
      name: "index_ip_telephone_occurrences_on_ip_occurrence_id",
      if_exists: true,
    )
    remove_index(
      :ip_staff_occurrences,
      column: :ip_occurrence_id,
      name: "index_ip_staff_occurrences_on_ip_occurrence_id",
      if_exists: true,
    )

    # Email occurrences
    remove_index(
      :email_zip_occurrences,
      column: :email_occurrence_id,
      name: "index_email_zip_occurrences_on_email_occurrence_id",
      if_exists: true,
    )
    remove_index(
      :email_user_occurrences,
      column: :email_occurrence_id,
      name: "index_email_user_occurrences_on_email_occurrence_id",
      if_exists: true,
    )
    remove_index(
      :email_telephone_occurrences,
      column: :email_occurrence_id,
      name: "index_email_telephone_occurrences_on_email_occurrence_id",
      if_exists: true,
    )
    remove_index(
      :email_staff_occurrences,
      column: :email_occurrence_id,
      name: "index_email_staff_occurrences_on_email_occurrence_id",
      if_exists: true,
    )
    remove_index(
      :email_ip_occurrences,
      column: :email_occurrence_id,
      name: "index_email_ip_occurrences_on_email_occurrence_id",
      if_exists: true,
    )

    # Domain occurrences
    remove_index(
      :domain_zip_occurrences,
      column: :domain_occurrence_id,
      name: "index_domain_zip_occurrences_on_domain_occurrence_id",
      if_exists: true,
    )
    remove_index(
      :domain_user_occurrences,
      column: :domain_occurrence_id,
      name: "index_domain_user_occurrences_on_domain_occurrence_id",
      if_exists: true,
    )
    remove_index(
      :domain_telephone_occurrences,
      column: :domain_occurrence_id,
      name: "index_domain_telephone_occurrences_on_domain_occurrence_id",
      if_exists: true,
    )
    remove_index(
      :domain_staff_occurrences,
      column: :domain_occurrence_id,
      name: "index_domain_staff_occurrences_on_domain_occurrence_id",
      if_exists: true,
    )
    remove_index(
      :domain_ip_occurrences,
      column: :domain_occurrence_id,
      name: "index_domain_ip_occurrences_on_domain_occurrence_id",
      if_exists: true,
    )
    remove_index(
      :domain_email_occurrences,
      column: :domain_occurrence_id,
      name: "index_domain_email_occurrences_on_domain_occurrence_id",
      if_exists: true,
    )

    # Area occurrences
    remove_index(
      :area_zip_occurrences,
      column: :area_occurrence_id,
      name: "index_area_zip_occurrences_on_area_occurrence_id",
      if_exists: true,
    )
    remove_index(
      :area_user_occurrences,
      column: :area_occurrence_id,
      name: "index_area_user_occurrences_on_area_occurrence_id",
      if_exists: true,
    )
    remove_index(
      :area_telephone_occurrences,
      column: :area_occurrence_id,
      name: "index_area_telephone_occurrences_on_area_occurrence_id",
      if_exists: true,
    )
    remove_index(
      :area_staff_occurrences,
      column: :area_occurrence_id,
      name: "index_area_staff_occurrences_on_area_occurrence_id",
      if_exists: true,
    )
    remove_index(
      :area_ip_occurrences,
      column: :area_occurrence_id,
      name: "index_area_ip_occurrences_on_area_occurrence_id",
      if_exists: true,
    )
    remove_index(
      :area_email_occurrences,
      column: :area_occurrence_id,
      name: "index_area_email_occurrences_on_area_occurrence_id",
      if_exists: true,
    )
    remove_index(
      :area_domain_occurrences,
      column: :area_occurrence_id,
      name: "index_area_domain_occurrences_on_area_occurrence_id",
      if_exists: true,
    )
  end
end
