class FixCorporateSiteContactTopicsForeignKey < ActiveRecord::Migration[8.1]
  def change
    # Remove the incorrect self-referential foreign key
    remove_foreign_key :corporate_site_contact_topics, column: :corporate_site_contact_topic_id if foreign_key_exists?(:corporate_site_contact_topics, column: :corporate_site_contact_topic_id)

    # Rename the column to the correct name
    rename_column :corporate_site_contact_topics, :corporate_site_contact_topic_id, :corporate_site_contact_id

    # Add the correct foreign key
    add_foreign_key :corporate_site_contact_topics, :corporate_site_contacts
  end
end
