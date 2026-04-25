# frozen_string_literal: true

class CreateScavengerRegionalStatuses < ActiveRecord::Migration[8.2]
  def change
    create_table(:scavenger_regional_statuses, id: :bigserial)
  end
end
