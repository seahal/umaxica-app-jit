# ToDo: Use table partitioning.

class CreateUniversalUserIdentifiers < ActiveRecord::Migration[8.0]
  def change
    create_table :universal_user_identifiers, id: :bytea do |t|
      t.string :otp_private_key
      t.datetime :last_otp_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.timestamps
    end
  end
end
