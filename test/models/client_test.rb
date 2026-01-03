# == Schema Information
#
# Table name: clients
#
#  id          :uuid             not null, primary key
#  public_id   :string
#  moniker     :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  status_id   :string(255)      default("NEYO"), not null
#  user_id     :uuid
#  division_id :uuid
#
# Indexes
#
#  index_clients_on_division_id  (division_id)
#  index_clients_on_public_id    (public_id) UNIQUE
#  index_clients_on_status_id    (status_id)
#  index_clients_on_user_id      (user_id)
#

# frozen_string_literal: true

require "test_helper"

class ClientTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
