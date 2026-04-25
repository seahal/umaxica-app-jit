# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: user_authorization_codes
# Database name: principal
#
#  id                    :bigint           not null, primary key
#  acr                   :string           default("aal1"), not null
#  auth_method           :string           default(""), not null
#  code                  :string(64)       not null
#  code_challenge        :string           not null
#  code_challenge_method :string(8)        default("S256"), not null
#  consumed_at           :datetime
#  nonce                 :string
#  redirect_uri          :text             not null
#  revoked_at            :datetime
#  scope                 :string
#  state                 :string
#  varnishable_at        :datetime         not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  client_id             :string(64)       not null
#  user_id               :bigint           not null
#
# Indexes
#
#  index_user_authorization_codes_on_code            (code) UNIQUE
#  index_user_authorization_codes_on_user_id         (user_id)
#  index_user_authorization_codes_on_varnishable_at  (varnishable_at)
#
class UserAuthorizationCode < PrincipalRecord
  include ::OidcAuthorizationCode

  belongs_to :user, inverse_of: :user_authorization_codes
end
