module Help
  module Com
    class ContactsController < ApplicationController
      include CloudflareTurnstile

      def show
      end

      def new
        @contact = ComContact.new
        @contact.com_contact_emails.build
        @contact.com_contact_telephones.build
        load_contact_categories
      end

      def create
        @contact = ComContact.new(contact_params)

        # Debug in test: check email values immediately after initialization
        if Rails.env.test?
          Rails.logger.debug "=== AFTER new() ==="
          @contact.com_contact_emails.each_with_index do |email, i|
            Rails.logger.debug "Email #{i}: #{email.email_address.inspect}"
          end
          Rails.logger.debug "=== END ==="
        end

        # Set expires_at for nested attributes if not already set
        @contact.com_contact_emails.each do |email|
          email.expires_at ||= 24.hours.from_now
        end
        @contact.com_contact_telephones.each do |telephone|
          telephone.expires_at ||= 24.hours.from_now
        end

        if turnstile_passed? && @contact.save
          redirect_to new_help_com_contact_email_path(contact_id: @contact.id), notice: t(".success")
        else
          # エラー時: 入力フィールドを表示するために最低1つのオブジェクトが必要
          # 既存のオブジェクトに入力値が保持されているので、空の場合のみ追加
          @contact.com_contact_emails.build if @contact.com_contact_emails.empty?
          @contact.com_contact_telephones.build if @contact.com_contact_telephones.empty?
          load_contact_categories
          render :new, status: :unprocessable_entity
        end
      end

      private

      def contact_params
        params.require(:com_contact).permit(
          :contact_category_title,
          :confirm_policy,
          com_contact_emails_attributes: [ :email_address ],
          com_contact_telephones_attributes: [ :telephone_number ]
        )
      end

      def load_contact_categories
        @contact_categories = ComContactCategory.order(:title)
      end

      def turnstile_passed?
        result = cloudflare_turnstile_validation
        return true if result["success"]
        @contact.errors.add(:base, :turnstile, message: t("help.com.contacts.create.turnstile_error"))
        false
      end
    end
  end
end
