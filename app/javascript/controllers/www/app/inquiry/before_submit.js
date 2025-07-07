//
const validness = {
	service_site_contact_confirm_policy: false,
	service_site_contact_email_address: false,
	service_site_contact_telephone_number: false,
};

const submitButton = document.querySelector('input[type="submit"]');
const service_site_contact_confirm_policy = document.querySelector(
	"#service_site_contact_confirm_policy",
);
const service_site_contact_email_address = document.querySelector(
	"#service_site_contact_email_address",
);
const service_site_contact_telephone_number = document.querySelector(
	"#service_site_contact_telephone_number",
);

submitButton.addEventListener("click", (e) => {
	if (Object.values(validness).every((value) => value === true)) {
		alert("Hello");
		// 条件が満たされたらフォームを送信したい場合、e.preventDefault() をここに置かない
		// または、特定の条件でのみ e.preventDefault() を実行する
	} else {
		e.preventDefault();
		alert("Please check the form");
	}
});
