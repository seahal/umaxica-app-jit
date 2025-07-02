import React from "react";
import { createRoot } from "react-dom/client";
import HelloWorld from "./components/concern/HelloWorld";
import EmailAddressInput from "./controllers/www/app/inquiry/EmailAddressInput";
import TelephoneNumberInput from "./controllers/www/app/inquiry/TelephoneNumberInput";

document.addEventListener("DOMContentLoaded", () => {
	const root = document.getElementById("root");
	if (root) {
		createRoot(root).render(<HelloWorld />);
	}

	const emailAddressInputRoot = document.getElementById(
		"www_app_inquiry_email_address_input",
	);
	if (emailAddressInputRoot) {
		createRoot(emailAddressInputRoot).render(<EmailAddressInput />);
	}
	const telephoneNumberInputRoot = document.getElementById(
		"www_app_inquiry_telephone_number_input",
	);
	if (telephoneNumberInputRoot) {
		createRoot(telephoneNumberInputRoot).render(<TelephoneNumberInput />);
	}
});
