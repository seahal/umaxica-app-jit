class CreateClientEmails < ActiveRecord::Migration[8.0]
  def change
    create_table :client_emails, id: :binary  do |t|
      t.string :address

      t.timestamps
    end
  end
end
