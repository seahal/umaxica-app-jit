# frozen_string_literal: true

class OrgDocumentAuditPolicy < ApplicationPolicy
  def index?
    false
  end

  def show?
    false
  end
end
