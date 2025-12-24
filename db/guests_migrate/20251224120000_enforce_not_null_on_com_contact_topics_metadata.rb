class EnforceNotNullOnComContactTopicsMetadata < ActiveRecord::Migration[8.2]
  def up
    execute "UPDATE com_contact_topics SET title = '' WHERE title IS NULL"
    execute "UPDATE com_contact_topics SET description = '' WHERE description IS NULL"

    change_table :com_contact_topics, bulk: true do |t|
      t.change_default :title, from: nil, to: ""
      t.change_default :description, from: nil, to: ""
      t.change_null :title, false
      t.change_null :description, false
    end
  end

  def down
    change_table :com_contact_topics, bulk: true do |t|
      t.change_null :title, true
      t.change_null :description, true
      t.change_default :title, from: "", to: nil
      t.change_default :description, from: "", to: nil
    end
  end
end
