import React from "react";
import { createRoot } from "react-dom/client";
import HelloWorld from "./components/concern/HelloWorld";
import EmailAddressInput from "./controllers/www/app/inquiries/EmailAddressInput";

document.addEventListener("DOMContentLoaded", () => {
	const root = document.getElementById("root");
	if (root) {
		createRoot(root).render(React.createElement(HelloWorld));
	}

	const emailAddressInputRoot = document.getElementById(
		"www_app_inquiry_email_address_input",
	);
	if (emailAddressInputRoot) {
		createRoot(emailAddressInputRoot).render(
			React.createElement(EmailAddressInput),
		);
	}

	const telephoneNumberInputRoot = document.getElementById(
		"www_app_inquiry_telephone_number_input",
	);
	if (telephoneNumberInputRoot) {
		createRoot(telephoneNumberInputRoot).render(
			React.createElement(EmailAddressInput),
		);
	}
});
