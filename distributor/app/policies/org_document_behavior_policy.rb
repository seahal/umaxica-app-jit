# typed: false
# frozen_string_literal: true

class OrgDocumentBehaviorPolicy < ApplicationPolicy
  def index?
    false
  end

  def show?
    false
  end
end
