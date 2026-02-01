# frozen_string_literal: true

# Migration to remove redundant indexes from timeline tables
# This resolves RedundantIndexChecker warnings
class RemoveRedundantTimelineIndexes < ActiveRecord::Migration[7.1]
  def change
    # OrgTimelineRevision
    remove_index :org_timeline_revisions,
                 name: "index_org_timeline_revisions_on_org_timeline_id",
                 if_exists: true

    # ComTimelineRevision
    remove_index :com_timeline_revisions,
                 name: "index_com_timeline_revisions_on_com_timeline_id",
                 if_exists: true

    # AppTimelineRevision
    remove_index :app_timeline_revisions,
                 name: "index_app_timeline_revisions_on_app_timeline_id",
                 if_exists: true
  end
end
