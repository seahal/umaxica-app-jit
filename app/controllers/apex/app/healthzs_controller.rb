# frozen_string_literal: true

module Apex
  module App
    class HealthzsController < ApplicationController
      include ::Health
    end
  end
end
