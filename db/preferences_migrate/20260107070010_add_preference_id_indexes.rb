# frozen_string_literal: true

class AddPreferenceIdIndexes < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    add_index(
      :app_preference_regions, :preference_id, name: "index_app_preference_regions_on_preference_id",
                                               if_not_exists: true, algorithm: :concurrently,
    )
    add_index(
      :app_preference_timezones, :preference_id, name: "index_app_preference_timezones_on_preference_id",
                                                 if_not_exists: true, algorithm: :concurrently,
    )
    add_index(
      :app_preference_languages, :preference_id, name: "index_app_preference_languages_on_preference_id",
                                                 if_not_exists: true, algorithm: :concurrently,
    )
    add_index(
      :app_preference_colorthemes, :preference_id, name: "index_app_preference_colorthemes_on_preference_id",
                                                   if_not_exists: true, algorithm: :concurrently,
    )
    add_index(
      :app_preference_cookies, :preference_id, name: "index_app_preference_cookies_on_preference_id",
                                               if_not_exists: true, algorithm: :concurrently,
    )

    add_index(
      :org_preference_regions, :preference_id, name: "index_org_preference_regions_on_preference_id",
                                               if_not_exists: true, algorithm: :concurrently,
    )
    add_index(
      :org_preference_timezones, :preference_id, name: "index_org_preference_timezones_on_preference_id",
                                                 if_not_exists: true, algorithm: :concurrently,
    )
    add_index(
      :org_preference_languages, :preference_id, name: "index_org_preference_languages_on_preference_id",
                                                 if_not_exists: true, algorithm: :concurrently,
    )
    add_index(
      :org_preference_colorthemes, :preference_id, name: "index_org_preference_colorthemes_on_preference_id",
                                                   if_not_exists: true, algorithm: :concurrently,
    )
    add_index(
      :org_preference_cookies, :preference_id, name: "index_org_preference_cookies_on_preference_id",
                                               if_not_exists: true, algorithm: :concurrently,
    )

    add_index(
      :com_preference_regions, :preference_id, name: "index_com_preference_regions_on_preference_id",
                                               if_not_exists: true, algorithm: :concurrently,
    )
    add_index(
      :com_preference_timezones, :preference_id, name: "index_com_preference_timezones_on_preference_id",
                                                 if_not_exists: true, algorithm: :concurrently,
    )
    add_index(
      :com_preference_languages, :preference_id, name: "index_com_preference_languages_on_preference_id",
                                                 if_not_exists: true, algorithm: :concurrently,
    )
    add_index(
      :com_preference_colorthemes, :preference_id, name: "index_com_preference_colorthemes_on_preference_id",
                                                   if_not_exists: true, algorithm: :concurrently,
    )
    add_index(
      :com_preference_cookies, :preference_id, name: "index_com_preference_cookies_on_preference_id",
                                               if_not_exists: true, algorithm: :concurrently,
    )
  end
end
