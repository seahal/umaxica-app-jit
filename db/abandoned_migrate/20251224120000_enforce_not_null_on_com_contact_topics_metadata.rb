# frozen_string_literal: true

class EnforceNotNullOnComContactTopicsMetadata < ActiveRecord::Migration[8.2]
  def up
    safety_assured { execute("UPDATE com_contact_topics SET title = '' WHERE title IS NULL") }
    safety_assured { execute("UPDATE com_contact_topics SET description = '' WHERE description IS NULL") }

    safety_assured do
      change_table(:com_contact_topics, bulk: true) do |t|
        t.change_default(:title, from: nil, to: "")
        t.change_default(:description, from: nil, to: "")
        t.change_null(:title, false)
        t.change_null(:description, false)
      end
    end
  end

  def down
    safety_assured do
      change_table(:com_contact_topics, bulk: true) do |t|
        t.change_null(:title, true)
        t.change_null(:description, true)
        t.change_default(:title, from: "", to: nil)
        t.change_default(:description, from: "", to: nil)
      end
    end
  end
end
