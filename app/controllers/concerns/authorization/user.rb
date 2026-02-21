# frozen_string_literal: true

module Authorization
  module User
    extend ActiveSupport::Concern

    include Authorization::Base
  end
end
