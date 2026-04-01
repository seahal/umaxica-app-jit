# frozen_string_literal: true

class CreateScavengerRegionalEvents < ActiveRecord::Migration[8.2]
  def change
    create_table(:scavenger_regional_events, id: :bigserial)
  end
end
