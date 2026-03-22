# typed: false
# frozen_string_literal: true

# INFORMATION: Look this docs. https://api.rubyonrails.org/classes/ActiveSupport/CurrentAttributes.html

# app/models/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :actor
  attribute :actor_type
  attribute :session
  attribute :token
  attribute :preference

  resets { self.preference = Current::Preference::NULL }

  # TODO: return :org, :app or :com
  def domain
  end

  def user?
    actor_type == :user
  end

  def staff?
    actor_type == :staff
  end

  def operator?
    actor_type == :operator
  end

  def member?
    actor_type == :member
  end

  def actor
    raise
  end

  # Preference is always available -- returns Current::Preference::NULL for guests/bearer tokens.
  # Assign a real Current::Preference after resolving from JWT or DB.
  #
  # Usage:
  #   Current.preference.language    # => "ja"
  #   Current.preference.cookie.consented?  # => false
  #   Current.preference.null?       # => true (for guests)
end
