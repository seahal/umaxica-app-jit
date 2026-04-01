# frozen_string_literal: true

class AddTitleAndBodyConstraintsToContactTopics < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      add_column(:app_contact_topics, :title, :string, limit: 80, default: "", null: false)
      add_column(:app_contact_topics, :description, :text)

      add_column(:org_contact_topics, :title, :string, limit: 80, default: "", null: false)
      add_column(:org_contact_topics, :description, :text)

      change_column(:com_contact_topics, :title, :string, limit: 80, default: "", null: false)
      change_column(:com_contact_topics, :description, :text)

      add_check_constraint(
        :app_contact_topics,
        "char_length(title) BETWEEN 1 AND 80",
        name: "chk_app_contact_topics_title_length",
      )
      add_check_constraint(
        :org_contact_topics,
        "char_length(title) BETWEEN 1 AND 80",
        name: "chk_org_contact_topics_title_length",
      )
      add_check_constraint(
        :com_contact_topics,
        "char_length(title) BETWEEN 1 AND 80",
        name: "chk_com_contact_topics_title_length",
      )

      add_check_constraint(
        :app_contact_topics,
        "description IS NULL OR char_length(description) <= 8000",
        name: "chk_app_contact_topics_description_length",
      )
      add_check_constraint(
        :org_contact_topics,
        "description IS NULL OR char_length(description) <= 8000",
        name: "chk_org_contact_topics_description_length",
      )
      add_check_constraint(
        :com_contact_topics,
        "description IS NULL OR char_length(description) <= 8000",
        name: "chk_com_contact_topics_description_length",
      )
    end
  end

  def down
    safety_assured do
      remove_check_constraint(:app_contact_topics, name: "chk_app_contact_topics_title_length")
      remove_check_constraint(:org_contact_topics, name: "chk_org_contact_topics_title_length")
      remove_check_constraint(:com_contact_topics, name: "chk_com_contact_topics_title_length")

      remove_check_constraint(:app_contact_topics, name: "chk_app_contact_topics_description_length")
      remove_check_constraint(:org_contact_topics, name: "chk_org_contact_topics_description_length")
      remove_check_constraint(:com_contact_topics, name: "chk_com_contact_topics_description_length")

      remove_column(:app_contact_topics, :title)
      remove_column(:app_contact_topics, :description)

      remove_column(:org_contact_topics, :title)
      remove_column(:org_contact_topics, :description)

      change_column(:com_contact_topics, :title, :string, limit: 255, default: nil, null: true)
      change_column(:com_contact_topics, :description, :text, limit: 4096)
    end
  end
end
