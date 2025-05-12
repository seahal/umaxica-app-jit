class CreateEntityStatuses < ActiveRecord::Migration[8.0]
  def change
    create_table :entity_statuses, id: :string do |t|
    end
  end
end
