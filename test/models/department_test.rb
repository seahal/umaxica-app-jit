# == Schema Information
#
# Table name: departments
#
#  id                   :uuid             not null, primary key
#  name                 :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  department_status_id :string(255)      default("NEYO"), not null
#  parent_id            :uuid
#  workspace_id         :uuid
#
# Indexes
#
#  index_departments_on_department_status_id                (department_status_id)
#  index_departments_on_department_status_id_and_parent_id  (department_status_id,parent_id) UNIQUE
#  index_departments_on_parent_id                           (parent_id)
#  index_departments_on_status_and_parent                   (department_status_id,parent_id) UNIQUE
#  index_departments_on_workspace_id                        (workspace_id)
#

# frozen_string_literal: true

require "test_helper"

class DepartmentTest < ActiveSupport::TestCase
  setup do
    @workspace = organizations(:one)
  end

  test "should be valid" do
    department = Department.new(
      name: "Test Dept",
      department_status_id: "NEYO",
      workspace: @workspace,
    )
    assert_predicate department, :valid?, department.errors.full_messages.to_sentence
  end

  test "requires name" do
    department = Department.new(department_status_id: "NEYO")
    assert_not department.valid?
    assert_includes department.errors[:name], "を入力してください"
  end
end
