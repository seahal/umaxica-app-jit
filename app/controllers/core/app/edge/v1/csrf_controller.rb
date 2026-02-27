# typed: false
# frozen_string_literal: true

module Core
  module App
    module Edge
      module V1
        class CsrfController < ApplicationController
          include ::Csrf
        end
      end
    end
  end
end
