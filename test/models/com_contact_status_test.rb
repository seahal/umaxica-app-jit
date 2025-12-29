# frozen_string_literal: true

# == Schema Information
#
# Table name: com_contact_statuses
#
#  id          :string(255)      not null, primary key
#  active      :boolean          default(TRUE), not null
#  description :string(255)      default(""), not null
#  parent_id   :string(255)      default("00000000-0000-0000-0000-000000000000"), not null
#  position    :integer          default(0), not null
#
# Indexes
#
#  index_com_contact_statuses_on_parent_id  (parent_id)
#

require "test_helper"

class ComContactStatusTest < ActiveSupport::TestCase
  setup do
    @model_class = ComContactStatus
    @valid_id = "ACTIVE".freeze
    @subject = @model_class.new(id: @valid_id)
  end
end
