# typed: false
# frozen_string_literal: true

# Shared account logic for Member and Operator.
# These are the organizational accounts linked to an identity (User or Staff).
module Account
  extend ActiveSupport::Concern

  include ::PublicId

  included do
    validates_reference_table :status_id, association: :"#{name.underscore}_status"
  end
end
