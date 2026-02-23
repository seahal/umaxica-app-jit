# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: divisions
# Database name: operator
#
#  id                 :bigint           not null, primary key
#  name               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  division_status_id :bigint           default(0), not null
#  organization_id    :bigint
#
# Indexes
#
#  index_divisions_on_division_status_id_and_organization_id  (division_status_id,organization_id) UNIQUE
#  index_divisions_on_organization_id                         (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (division_status_id => division_statuses.id)
#  fk_rails_...  (organization_id => organizations.id) ON DELETE => nullify
#

require "test_helper"

class DivisionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
