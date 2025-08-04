# frozen_string_literal: true

module PunditBase
  extend ActiveSupport::Concern

  included do
    include Pundit::Authorization
    allow_browser versions: :modern
  end
end
