# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customers
# Database name: guest
#
#  id                   :bigint           not null, primary key
#  deactivated_at       :datetime
#  deletable_at         :datetime         default(Infinity), not null
#  lock_version         :integer          default(0), not null
#  multi_factor_enabled :boolean          default(FALSE), not null
#  shreddable_at        :datetime         default(Infinity), not null
#  withdrawn_at         :datetime         default(Infinity)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  public_id            :string           default(""), not null
#  status_id            :bigint           default(2), not null
#  visibility_id        :bigint           default(1), not null
#
# Indexes
#
#  index_customers_on_deactivated_at  (deactivated_at) WHERE (deactivated_at IS NOT NULL)
#  index_customers_on_deletable_at    (deletable_at)
#  index_customers_on_public_id       (public_id) UNIQUE
#  index_customers_on_shreddable_at   (shreddable_at)
#  index_customers_on_status_id       (status_id)
#  index_customers_on_visibility_id   (visibility_id)
#  index_customers_on_withdrawn_at    (withdrawn_at) WHERE (withdrawn_at IS NOT NULL)
#
# Foreign Keys
#
#  fk_rails_...  (status_id => customer_statuses.id)
#  fk_rails_...  (visibility_id => customer_visibilities.id)
#

require "test_helper"

class CustomerTest < ActiveSupport::TestCase
  def setup
    [1, 2, 3].each { |id| CustomerStatus.find_or_create_by!(id: id) }
    [0, 1, 2, 3].each { |id| CustomerVisibility.find_or_create_by!(id: id) }
  end

  test "should be valid" do
    customer = Customer.create!

    assert_predicate customer, :valid?
  end

  test "public_id is auto-generated" do
    customer = Customer.create!

    assert_predicate customer.public_id, :present?
    assert_operator customer.public_id.length, :<=, 21
  end

  test "default status_id is nothing" do
    customer = Customer.create!

    assert_equal CustomerStatus::NOTHING, customer.status_id
  end

  test "default visibility_id is customer" do
    customer = Customer.create!

    assert_equal CustomerVisibility::CUSTOMER, customer.visibility_id
  end

  test "customer? should return true" do
    customer = Customer.create!

    assert_predicate customer, :customer?
  end

  test "user? should return false" do
    customer = Customer.create!

    assert_not customer.user?
  end

  test "staff? should return false" do
    customer = Customer.create!

    assert_not customer.staff?
  end

  test "login_allowed? is false for reserved status" do
    customer = Customer.create!(status_id: CustomerStatus::RESERVED)

    assert_not customer.login_allowed?
  end
end
