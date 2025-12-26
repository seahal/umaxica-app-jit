# frozen_string_literal: true

module Accountable
  extend ActiveSupport::Concern

  included do
    has_one :account, as: :accountable, touch: true, dependent: :destroy
  end
end
