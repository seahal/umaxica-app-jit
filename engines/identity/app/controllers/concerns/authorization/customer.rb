# typed: false
# frozen_string_literal: true

module Authorization
  module Customer
    extend ActiveSupport::Concern

    include Authorization::Base
  end
end
