# frozen_string_literal: true

module Core
  module Org
    module V1
      class CsrfController < ApplicationController
        include ::Csrf
      end
    end
  end
end
