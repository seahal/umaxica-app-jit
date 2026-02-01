# frozen_string_literal: true

# == Schema Information
#
# Table name: client_statuses
# Database name: principal
#
#  id :integer          not null, primary key
#
class ClientStatus < PrincipalRecord
  include CodeIdentifiable

  self.record_timestamps = false
  NEYO = "NEYO"
  has_many :clients,
           foreign_key: :status_id,
           dependent: :restrict_with_error,
           inverse_of: :client_status
end
