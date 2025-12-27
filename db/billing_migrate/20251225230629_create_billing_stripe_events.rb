# frozen_string_literal: true

class CreateBillingStripeEvents < ActiveRecord::Migration[8.2]
  def change
    create_table :billing_stripe_events, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.string :event_id, null: false
      t.string :event_type, null: false
      t.boolean :livemode, null: false, default: false
      t.jsonb :payload_json, null: false
      t.datetime :received_at, null: false

      t.timestamps
    end

    add_index :billing_stripe_events, :event_id, unique: true
    add_index :billing_stripe_events, :received_at
  end
end
