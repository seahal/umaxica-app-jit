class CreateUniversalEmailIdentifiers < ActiveRecord::Migration[7.2]
  def change
    create_table :universal_email_identifiers, id: :binary do |t|
      t.timestamps
    end
  end
end
