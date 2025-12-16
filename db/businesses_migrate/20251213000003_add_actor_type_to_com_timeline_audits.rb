class AddActorTypeToComTimelineAudits < ActiveRecord::Migration[8.2]
  def change
    add_column :com_timeline_audits, :actor_type, :string
  end
end
