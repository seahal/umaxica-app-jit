# frozen_string_literal: true

class Sign::Org::Configuration::ChallengesController < ApplicationController
  include ::Auth::VerificationEnforcer

  before_action :authenticate_staff!

  def show
  end

  def update
  end

  private

  def verification_required_action?
    action_name == "update"
  end

  def verification_scope
    "configuration_mfa"
  end
end
