# typed: false
# == Schema Information
#
# Table name: clients
# Database name: principal
#
#  id               :bigint           not null, primary key
#  lock_version     :integer          default(0), not null
#  moniker          :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  client_status_id :bigint           default(0), not null
#  division_id      :bigint
#  public_id        :string           not null
#  status_id        :bigint           default(5), not null
#  user_id          :bigint
#
# Indexes
#
#  index_clients_on_client_status_id  (client_status_id)
#  index_clients_on_division_id       (division_id)
#  index_clients_on_public_id         (public_id) UNIQUE
#  index_clients_on_status_id         (status_id)
#  index_clients_on_user_id           (user_id)
#
# Foreign Keys
#
#  fk_clients_on_client_status_id  (client_status_id => client_statuses.id)
#  fk_clients_on_status_id         (status_id => client_statuses.id)
#  fk_rails_...                    (client_status_id => client_statuses.id)
#  fk_rails_...                    (user_id => users.id) ON DELETE => nullify
#

# frozen_string_literal: true

require "test_helper"

class ClientTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
