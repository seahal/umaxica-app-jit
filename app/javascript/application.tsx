import { createRoot } from "react-dom/client";
import HelloWorld from "./components/HelloWorld";
import EmailAddress from "./components/www/app/email_address";

document.addEventListener("DOMContentLoaded", () => {
	const email_address = document.getElementById("email_address");
	if (email_address) {
		const emailRoot = createRoot(email_address);
		emailRoot.render(<EmailAddress />);
	}
});
