# frozen_string_literal: true

class AddTitleAndDescriptionToComContactTopics < ActiveRecord::Migration[8.2]
  def change
    change_table :com_contact_topics, bulk: true do |t|
      t.string :title
      t.text :description
    end
  end
end
