# frozen_string_literal: true

class ComDocumentAuditPolicy < ApplicationPolicy
  def index?
    false
  end

  def show?
    false
  end
end
