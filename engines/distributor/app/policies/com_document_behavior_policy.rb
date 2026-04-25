# typed: false
# frozen_string_literal: true

class ComDocumentBehaviorPolicy < ApplicationPolicy
  def index?
    false
  end

  def show?
    false
  end
end
