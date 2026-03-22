# frozen_string_literal: true

class CreateComTimelineRevisions < ActiveRecord::Migration[8.2]
  def change
    create_table(:com_timeline_revisions) do |t|
      t.references(:com_timeline, null: false, foreign_key: true, type: :bigint)
      t.string(:permalink, null: false, limit: 200)
      t.string(:response_mode, null: false)
      t.string(:redirect_url)
      t.string(:title)
      t.string(:description)
      t.text(:body)
      t.datetime(:published_at, null: false)
      t.datetime(:expires_at, null: false)
      t.string(:edited_by_type)
      t.bigint(:edited_by_id)
      t.string(:public_id, limit: 255, default: "", null: false)

      t.timestamps
    end

    add_index(:com_timeline_revisions, [:com_timeline_id, :created_at])
    add_index(:com_timeline_revisions, :public_id, unique: true)
  end
end
