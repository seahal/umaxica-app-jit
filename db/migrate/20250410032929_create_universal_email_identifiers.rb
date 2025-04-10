class CreateUniversalEmailIdentifiers < ActiveRecord::Migration[8.1]
  def change
    create_table :universal_email_identifiers do |t|
      t.timestamps
    end
  end
end
