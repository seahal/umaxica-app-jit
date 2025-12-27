# frozen_string_literal: true

module Core
  module App
    module V1
      class CsrfController < ApplicationController
        include ::Csrf
      end
    end
  end
end
