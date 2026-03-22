# frozen_string_literal: true

class ValidateCheckConstraintsAndApplyNotNullScavengerRegionals < ActiveRecord::Migration[8.2]
  def up
    return unless table_exists?(:scavenger_regionals)

    validate_check_constraint(:scavenger_regionals, name: "scavenger_regionals_region_id_null")
    validate_check_constraint(:scavenger_regionals, name: "scavenger_regionals_job_type_null")
    validate_check_constraint(:scavenger_regionals, name: "scavenger_regionals_idempotency_key_null")

    change_column_null(:scavenger_regionals, :region_id, false)
    change_column_null(:scavenger_regionals, :job_type, false)
    change_column_null(:scavenger_regionals, :idempotency_key, false)

    remove_check_constraint(:scavenger_regionals, name: "scavenger_regionals_region_id_null")
    remove_check_constraint(:scavenger_regionals, name: "scavenger_regionals_job_type_null")
    remove_check_constraint(:scavenger_regionals, name: "scavenger_regionals_idempotency_key_null")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
