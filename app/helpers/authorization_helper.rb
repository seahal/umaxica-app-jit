# frozen_string_literal: true

# Helper methods for checking authorization in views
module AuthorizationHelper
  # Check if current actor is authorized for a given action on a record
  # @param record [Object] The record to check authorization for
  # @param action [Symbol] The action to check (e.g., :show?, :edit?, :destroy?)
  # @return [Boolean]
  #
  # Example in view:
  #   <% if authorized?(@document, :edit?) %>
  #     <%= link_to "Edit", edit_document_path(@document) %>
  #   <% end %>
  def authorized?(record, action)
    return false unless current_actor

    policy = policy(record)
    policy.public_send(action)
  rescue Pundit::NotDefinedError
    false
  end

  # Check if current actor has a specific role
  # @param role_key [String] Role key (e.g., 'admin', 'editor')
  # @param organization [Organization, nil] Optional organization scope
  # @return [Boolean]
  #
  # Example in view:
  #   <% if has_role?('admin') %>
  #     <%= link_to "Admin Panel", admin_path %>
  #   <% end %>
  def has_role?(role_key, organization: nil)
    return false unless current_actor&.respond_to?(:has_role?)

    current_actor.has_role?(role_key, organization: organization)
  end

  # Check if current actor has any of the specified roles
  # @param role_keys [Array<String>] Role keys to check
  # @param organization [Organization, nil] Optional organization scope
  # @return [Boolean]
  #
  # Example in view:
  #   <% if has_any_role?('admin', 'manager') %>
  #     <%= render 'management_tools' %>
  #   <% end %>
  def has_any_role?(*role_keys, organization: nil)
    return false unless current_actor&.respond_to?(:has_any_role?)

    current_actor.has_any_role?(*role_keys, organization: organization)
  end

  # Check if current actor is admin
  # @param organization [Organization, nil] Optional organization scope
  # @return [Boolean]
  def admin?(organization: nil)
    has_role?("admin", organization: organization)
  end

  # Check if current actor is admin or manager
  # @param organization [Organization, nil] Optional organization scope
  # @return [Boolean]
  def admin_or_manager?(organization: nil)
    has_any_role?("admin", "manager", organization: organization)
  end

  # Check if current actor can edit resources
  # @param organization [Organization, nil] Optional organization scope
  # @return [Boolean]
  def can_edit?(organization: nil)
    return false unless current_actor&.respond_to?(:can_edit?)

    current_actor.can_edit?(organization: organization)
  end

  # Check if current actor can view resources
  # @param organization [Organization, nil] Optional organization scope
  # @return [Boolean]
  def can_view?(organization: nil)
    return false unless current_actor&.respond_to?(:can_view?)

    current_actor.can_view?(organization: organization)
  end

  # Check if current actor can contribute (create content)
  # @param organization [Organization, nil] Optional organization scope
  # @return [Boolean]
  def can_contribute?(organization: nil)
    return false unless current_actor&.respond_to?(:can_contribute?)

    current_actor.can_contribute?(organization: organization)
  end

  # Render content only if authorized
  # @param record [Object] The record to check authorization for
  # @param action [Symbol] The action to check
  # @yield Block to render if authorized
  #
  # Example in view:
  #   <%= if_authorized @document, :edit? do %>
  #     <%= link_to "Edit", edit_document_path(@document) %>
  #   <% end %>
  def if_authorized(record, action, &)
    yield if authorized?(record, action)
  end

  # Render content only if current actor has role
  # @param role_key [String] Role key to check
  # @param organization [Organization, nil] Optional organization scope
  # @yield Block to render if has role
  #
  # Example in view:
  #   <%= if_has_role 'admin' do %>
  #     <%= render 'admin_panel' %>
  #   <% end %>
  def if_has_role(role_key, organization: nil)
    yield if has_role?(role_key, organization: organization)
  end

  private

  # Get current actor (User or Staff)
  def current_actor
    @current_actor ||=
      begin
        if respond_to?(:current_user) && current_user
          current_user
        elsif respond_to?(:current_staff) && current_staff
          current_staff
        end
      end
  end
end
