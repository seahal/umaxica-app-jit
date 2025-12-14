class AddActorTypeToAppTimelineAudits < ActiveRecord::Migration[8.2]
  def change
    add_column :app_timeline_audits, :actor_type, :string
  end
end
