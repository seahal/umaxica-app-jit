# frozen_string_literal: true

# Migration to add latest_version_id and latest_revision_id columns to timeline tables
# This resolves ForeignKeyTypeChecker warnings for timeline associations
class AddLatestVersionAndRevisionToTimelines < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    # App Timelines
    add_column(:app_timelines, :latest_version_id, :bigint)
    add_column(:app_timelines, :latest_revision_id, :bigint)

    add_foreign_key(
      :app_timelines, :app_timeline_versions,
      column: :latest_version_id,
      on_delete: :nullify,
      validate: false,
    )
    add_foreign_key(
      :app_timelines, :app_timeline_revisions,
      column: :latest_revision_id,
      on_delete: :nullify,
      validate: false,
    )

    add_index(
      :app_timelines, :latest_version_id,
      name: "index_app_timelines_on_latest_version_id",
      unique: true,
      algorithm: :concurrently,
    )
    add_index(
      :app_timelines, :latest_revision_id,
      name: "index_app_timelines_on_latest_revision_id",
      unique: true,
      algorithm: :concurrently,
    )

    # Com Timelines
    add_column(:com_timelines, :latest_version_id, :bigint)
    add_column(:com_timelines, :latest_revision_id, :bigint)

    add_foreign_key(
      :com_timelines, :com_timeline_versions,
      column: :latest_version_id,
      on_delete: :nullify,
      validate: false,
    )
    add_foreign_key(
      :com_timelines, :com_timeline_revisions,
      column: :latest_revision_id,
      on_delete: :nullify,
      validate: false,
    )

    add_index(
      :com_timelines, :latest_version_id,
      name: "index_com_timelines_on_latest_version_id",
      unique: true,
      algorithm: :concurrently,
    )
    add_index(
      :com_timelines, :latest_revision_id,
      name: "index_com_timelines_on_latest_revision_id",
      unique: true,
      algorithm: :concurrently,
    )

    # Org Timelines
    add_column(:org_timelines, :latest_version_id, :bigint)
    add_column(:org_timelines, :latest_revision_id, :bigint)

    add_foreign_key(
      :org_timelines, :org_timeline_versions,
      column: :latest_version_id,
      on_delete: :nullify,
      validate: false,
    )
    add_foreign_key(
      :org_timelines, :org_timeline_revisions,
      column: :latest_revision_id,
      on_delete: :nullify,
      validate: false,
    )

    add_index(
      :org_timelines, :latest_version_id,
      name: "index_org_timelines_on_latest_version_id",
      unique: true,
      algorithm: :concurrently,
    )
    add_index(
      :org_timelines, :latest_revision_id,
      name: "index_org_timelines_on_latest_revision_id",
      unique: true,
      algorithm: :concurrently,
    )
  end
end
