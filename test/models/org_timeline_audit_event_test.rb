# frozen_string_literal: true

# == Schema Information
#
# Table name: org_timeline_audit_events
#
#  id :string(255)      default("NEYO"), not null, primary key
#

require "test_helper"

class OrgTimelineAuditEventTest < ActiveSupport::TestCase
  setup do
    @model_class = OrgTimelineAuditEvent
    @valid_id = "CREATED".freeze
    @subject = @model_class.new(id: @valid_id)
  end
end
