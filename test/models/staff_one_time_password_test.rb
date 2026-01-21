# == Schema Information
#
# Table name: staff_one_time_passwords
#
#  id                                :uuid             not null, primary key
#  staff_id                          :uuid             not null
#  private_key                       :string(1024)     default(""), not null
#  last_otp_at                       :datetime         default("-infinity"), not null
#  public_id                         :string(21)
#  title                             :string(32)
#  staff_one_time_password_status_id :string           default("NEYO"), not null
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#
# Indexes
#
#  idx_on_staff_one_time_password_status_id_8958a1c9bf  (staff_one_time_password_status_id)
#  index_staff_one_time_passwords_on_public_id          (public_id) UNIQUE
#  index_staff_one_time_passwords_on_staff_id           (staff_id)
#

# frozen_string_literal: true

require "test_helper"

class StaffOneTimePasswordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
