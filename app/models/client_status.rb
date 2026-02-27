# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: client_statuses
# Database name: principal
#
#  id :bigint           not null, primary key
#
class ClientStatus < PrincipalRecord
  self.record_timestamps = false

  ACTIVE = 1
  INACTIVE = 2
  PENDING = 3
  DELETED = 4
  NOTHING = 5
  has_many :clients,
           foreign_key: :status_id,
           dependent: :restrict_with_error,
           inverse_of: :client_status
end
