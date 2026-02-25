# frozen_string_literal: true

class AddCheckConstraintsToScavengerRegionals < ActiveRecord::Migration[8.2]
  def change
    return unless table_exists?(:scavenger_regionals)

    add_check_constraint :scavenger_regionals, "region_id IS NOT NULL", name: "scavenger_regionals_region_id_null", validate: false
    add_check_constraint :scavenger_regionals, "job_type IS NOT NULL", name: "scavenger_regionals_job_type_null", validate: false
    add_check_constraint :scavenger_regionals, "idempotency_key IS NOT NULL", name: "scavenger_regionals_idempotency_key_null", validate: false
  end
end
