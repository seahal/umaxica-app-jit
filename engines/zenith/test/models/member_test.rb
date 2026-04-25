# typed: false
# == Schema Information
#
# Table name: members
# Database name: principal
#
#  id            :bigint           not null, primary key
#  moniker       :string
#  shreddable_at :datetime         default(Infinity), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  division_id   :bigint
#  public_id     :string           not null
#  status_id     :bigint           default(5), not null
#  user_id       :bigint
#
# Indexes
#
#  index_members_on_division_id    (division_id)
#  index_members_on_public_id      (public_id) UNIQUE
#  index_members_on_shreddable_at  (shreddable_at)
#  index_members_on_status_id      (status_id)
#  index_members_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (status_id => member_statuses.id)
#  fk_rails_...  (user_id => users.id) ON DELETE => nullify
#

# frozen_string_literal: true

require "test_helper"

class MemberTest < ActiveSupport::TestCase
  test "class is defined" do
    assert_equal "Member", Member.name
  end

  test "shreddable scope excludes members with shreddable_at in the future" do
    member = Member.create!

    assert_not_includes Member.shreddable, member
  end

  test "shreddable scope includes members with shreddable_at in the past" do
    member = Member.create!(shreddable_at: 1.second.ago)

    assert_includes Member.shreddable, member
  end
end
