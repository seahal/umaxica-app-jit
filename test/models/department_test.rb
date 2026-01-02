# == Schema Information
#
# Table name: departments
#
#  id                   :uuid             not null, primary key
#  parent_id            :uuid
#  department_status_id :string(255)      not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_departments_on_department_status_id  (department_status_id)
#  index_organizations_unique                 (parent_id,department_status_id) UNIQUE
#

# frozen_string_literal: true

require "test_helper"

class DepartmentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
