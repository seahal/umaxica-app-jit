# == Schema Information
#
# Table name: clients
# Database name: principal
#
#  id           :bigint           not null, primary key
#  lock_version :integer          default(0), not null
#  moniker      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  division_id  :bigint
#  public_id    :string
#  status_id    :integer          default(0), not null
#  user_id      :bigint
#
# Indexes
#
#  index_clients_on_division_id  (division_id)
#  index_clients_on_public_id    (public_id) UNIQUE
#  index_clients_on_status_id    (status_id)
#  index_clients_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (status_id => client_statuses.id)
#  fk_rails_...  (user_id => users.id)
#

# frozen_string_literal: true

require "test_helper"

class ClientTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
