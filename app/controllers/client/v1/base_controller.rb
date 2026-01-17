# frozen_string_literal: true

# NOTE: This app already defines a `Client` model (class), so we reopen it as a
# class here (not a module) and define `Client::V1::*` under it.
class Client
  module V1
    class BaseController < ApplicationController
      # Client API is called from native/external clients and uses
      # Authorization: Bearer <JWT> authentication.
      # Auth expiry must yield 401.
      #
      # NOTE: Auth mechanism itself is intentionally NOT implemented here.
    end
  end
end
