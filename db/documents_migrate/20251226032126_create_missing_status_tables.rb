class CreateMissingStatusTables < ActiveRecord::Migration[8.2]
  PREFIXES = %w(org com app).freeze
  TYPES = %w(document).freeze

  def change
    PREFIXES.each do |prefix|
      TYPES.each do |type|
        table_name = "#{prefix}_#{type}_statuses"
        create_table table_name, id: { type: :string, limit: 255 } do |t|
          t.boolean :active, default: true, null: false
          t.string :description, limit: 255, default: "", null: false
          t.integer :position, default: 0, null: false
          t.timestamps

          # Add standard indexes and constraints for statuses
          t.index "lower((id)::text)", name: "index_#{table_name}_on_lower_id", unique: true
          t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_#{table_name}_id_format"
        end
      end
    end
  end
end
