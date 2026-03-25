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

class Customer < GuestRecord
  include ::PublicId
  include ::Identity

  LOGIN_BLOCKED_STATUS_IDS = [CustomerStatus::RESERVED].freeze

  attribute :status_id, default: CustomerStatus::NOTHING

  belongs_to :customer_status,
             class_name: "CustomerStatus",
             foreign_key: :status_id,
             inverse_of: :customers
  belongs_to :visibility,
             class_name: "CustomerVisibility",
             inverse_of: :customers

  def staff?
    false
  end

  def user?
    false
  end

  def customer?
    true
  end
end
