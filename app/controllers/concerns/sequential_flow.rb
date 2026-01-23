# frozen_string_literal: true

# Sequential Flow Enforcement Concern
#
# Provides a declarative state machine for enforcing ordered step progression
# in multi-step flows (e.g., registration, onboarding).
#
# == Example:
#
#   class RegistrationController < ApplicationController
#     include SequentialFlow
#
#     flow :registration do
#       step 1, actions: %i[new create]
#       step 2, actions: %i[edit update]
#       step 3, actions: %i[show destroy]
#     end
#
#     before_action :enforce_flow!
#
#     def create
#       if success
#         advance_step!
#         redirect_to edit_path
#       end
#     end
#   end
#
# == Design:
#
# - State stored in `session[:flows][flow_name]`
# - Initial step is always 1
# - `advance_step!` moves to next step (call on create/update success)
# - `reset_flow!` clears flow state (call on destroy or cancel)
# - `enforce_flow!` redirects with flash if action not allowed at current step
#
require "concurrent/map"

module SequentialFlow
  extend ActiveSupport::Concern

  FLOW_REGISTRY = Concurrent::Map.new

  class_methods do
    # DSL entry point: define a flow with a block
    def flow(name, &)
      definition = FlowDefinition.new(name)
      flow_definitions[name.to_sym] = definition
      FlowBuilder.new(definition).instance_exec(&)
    end

    def flow_definitions
      FLOW_REGISTRY.fetch_or_store(self) { {} }
    end
  end

  class FlowBuilder
    def initialize(definition)
      @definition = definition
    end

    def step(number, actions:)
      @definition.add_step(number, actions)
    end
  end

  # Holds the step -> actions mapping for a flow
  class FlowDefinition
    attr_reader :name, :steps, :action_to_step

    def initialize(name)
      @name = name
      @steps = {}             # { step_number => [actions] }
      @action_to_step = {}    # { action_sym => step_number }
    end

    def add_step(number, actions)
      @steps[number] = actions.map(&:to_sym)
      actions.each { |a| @action_to_step[a.to_sym] = number }
    end

    def initial_step
      @steps.keys.min
    end

    def final_step
      @steps.keys.max
    end

    def allowed_actions_for_step(step_number)
      @steps[step_number] || []
    end

    def step_for_action(action)
      @action_to_step[action.to_sym]
    end

    def valid_step?(step_number)
      @steps.key?(step_number)
    end
  end

  private

  # Get the current flow definition (uses controller's defined flow)
  def current_flow
    self.class.flow_definitions.values.first
  end

  # Get flow name for session key
  def flow_session_key
    "flows_#{current_flow.name}"
  end

  # Current step from session (defaults to initial step)
  def current_step
    session[flow_session_key] || current_flow.initial_step
  end

  # Set the current step
  def current_step=(step)
    session[flow_session_key] = step
  end

  # Check if the current action is allowed at the current step
  def action_allowed?
    flow = current_flow
    return true if flow.nil?

    required_step = flow.step_for_action(action_name)
    return true if required_step.nil? # Action not part of flow

    current_step == required_step
  end

  # Enforce the flow: redirect if action not allowed
  # Override `flow_violation_redirect` to customize behavior
  def enforce_flow!
    return if action_allowed?

    flow_violation_redirect
  end

  # Advance to the next step (call after successful create/update)
  def advance_step!
    flow = current_flow
    return unless flow

    next_step = current_step + 1
    self.current_step = next_step if flow.valid_step?(next_step)
  end

  # Reset flow to initial step (call on destroy or explicit reset)
  def reset_flow!
    session.delete(flow_session_key)
  end

  # Override in controller to customize redirect behavior
  def flow_violation_redirect
    flash[:alert] = t("sequential_flow.invalid_step")
    redirect_to flow_initial_path
  end

  # Override in controller to specify the initial path
  def flow_initial_path
    raise NotImplementedError, "Define #flow_initial_path in your controller"
  end
end
