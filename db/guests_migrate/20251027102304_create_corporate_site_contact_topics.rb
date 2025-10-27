class CreateCorporateSiteContactTopics < ActiveRecord::Migration[8.1]
  def change
    create_table :corporate_site_contact_topics, id: :uuid do |t|
      t.references :corporate_site_contact_topic, null: false, foreign_key: true, type: :uuid
      t.string :title, default: "", null: false, limit: 255
      t.text :description, default: "", null: false, limit: 10000
      t.boolean :deletable, default: false, null: false
      t.timestamps
    end
  end
end
