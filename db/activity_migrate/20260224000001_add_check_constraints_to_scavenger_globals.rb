# frozen_string_literal: true

class AddCheckConstraintsToScavengerGlobals < ActiveRecord::Migration[8.2]
  def change
    return unless table_exists?(:scavenger_globals)

    add_check_constraint(
      :scavenger_globals, "job_type IS NOT NULL", name: "scavenger_globals_job_type_null",
                                                  validate: false,
    )
    add_check_constraint(
      :scavenger_globals, "idempotency_key IS NOT NULL",
      name: "scavenger_globals_idempotency_key_null", validate: false,
    )
  end
end
