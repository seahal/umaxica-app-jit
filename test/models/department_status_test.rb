# frozen_string_literal: true

# == Schema Information
#
# Table name: department_statuses
# Database name: operator
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_department_statuses_on_code  (code) UNIQUE
#
require "test_helper"

class DepartmentStatusTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
