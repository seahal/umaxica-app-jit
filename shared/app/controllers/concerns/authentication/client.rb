# typed: false
# frozen_string_literal: true

module Authentication
  module Client
    extend ActiveSupport::Concern

    include Authentication::Base
  end
end
