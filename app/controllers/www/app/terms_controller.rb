# frozen_string_literal: true

module Www
  module App
    class TermsController < ApplicationController
      def show
        render plain: "kiyaku"
      end
    end
  end
end
