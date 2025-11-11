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

        if turnstile_passed? && @contact.save
          redirect_to edit_help_com_contact_email_path(@contact), notice: t(".success")
        else
          # エラー時に、パラメータから関連レコードが作成されていない場合のみ空のレコードを追加
          @contact.com_contact_emails.build if @contact.com_contact_emails.empty?
          @contact.com_contact_telephones.build if @contact.com_contact_telephones.empty?
          load_contact_categories
          render :new, status: :unprocessable_entity
        end
      end

      private

      def contact_params
        params.expect(
          com_contact: [ :contact_category_title,
          :confirm_policy,
          com_contact_emails_attributes: [ :email_address ],
          com_contact_telephones_attributes: [ :telephone_number ] ]
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
