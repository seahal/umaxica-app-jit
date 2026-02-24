# frozen_string_literal: true

class ValidateCheckConstraintsAndApplyNotNullScavengerGlobals < ActiveRecord::Migration[8.2]
  def up
    validate_check_constraint :scavenger_globals, name: "scavenger_globals_job_type_null"
    validate_check_constraint :scavenger_globals, name: "scavenger_globals_idempotency_key_null"

    change_column_null :scavenger_globals, :job_type, false
    change_column_null :scavenger_globals, :idempotency_key, false

    remove_check_constraint :scavenger_globals, name: "scavenger_globals_job_type_null"
    remove_check_constraint :scavenger_globals, name: "scavenger_globals_idempotency_key_null"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
