# ToDo: Use table partitioning.
# INFO: Use lowercase for emails address

class CreateUniversalEmailIdentifiers < ActiveRecord::Migration[8.0]
  def change
    create_table :universal_email_identifiers, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.timestamps
    end
  end
end
