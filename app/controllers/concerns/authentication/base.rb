# typed: false
# frozen_string_literal: true

module Authentication
  module Base
    extend ActiveSupport::Concern

    include ::Auth::Base
  end
end
