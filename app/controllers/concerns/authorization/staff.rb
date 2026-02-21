# frozen_string_literal: true

module Authorization
  module Staff
    extend ActiveSupport::Concern

    include Authorization::Base
  end
end
