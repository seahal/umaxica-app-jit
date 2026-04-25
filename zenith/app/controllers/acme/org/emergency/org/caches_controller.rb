# typed: false
# frozen_string_literal: true

class Acme::Org::Emergency::Org::CachesController < ApplicationController
  def show
    head :ok
  end

  def update
    head :no_content
  end

  def destroy
    head :no_content
  end
end
