# == Schema Information
#
# Table name: admins
#
#  id         :uuid             not null, primary key
#  public_id  :string
#  moniker    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  status_id  :string(255)      default("NEYO"), not null
#  staff_id   :uuid             not null
#
# Indexes
#
#  index_admins_on_public_id  (public_id) UNIQUE
#  index_admins_on_staff_id   (staff_id)
#  index_admins_on_status_id  (status_id)
#

# frozen_string_literal: true

require "test_helper"

class AdminTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
