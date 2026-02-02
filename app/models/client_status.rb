# frozen_string_literal: true

# == Schema Information
#
# Table name: client_statuses
# Database name: principal
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_client_statuses_on_code  (code) UNIQUE
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
