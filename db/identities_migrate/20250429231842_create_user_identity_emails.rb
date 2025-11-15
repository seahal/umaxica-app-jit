class CreateUserIdentityEmails < ActiveRecord::Migration[8.0]
  def change
    create_table :user_identity_emails, id: :uuid do |t|
      t.references :user
      t.string :address
      t.timestamps
    end
  end
end
