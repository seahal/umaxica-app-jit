# == Schema Information
#
# Table name: departments
#
#  id                   :uuid             not null, primary key
#  name                 :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  department_status_id :string(255)
#  workspace_id         :uuid
#  parent_id            :uuid
#
# Indexes
#
#  index_departments_on_department_status_id  (department_status_id)
#  index_departments_on_parent_id             (parent_id)
#  index_departments_on_status_and_parent     (department_status_id,parent_id) UNIQUE
#  index_departments_on_workspace_id          (workspace_id)
#

# frozen_string_literal: true

require "test_helper"

class DepartmentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
