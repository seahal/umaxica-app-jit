import { createRoot } from "react-dom/client";
import App from "./components/common/App";
import EmailAddress from "./components/www/app/email_address";

document.addEventListener("DOMContentLoaded", () => {
	const container = document.getElementById("react-root");
	if (container) {
		const root = createRoot(container);
		root.render(<App />);
	}

	const email_address = document.getElementById("email_address");
	if (email_address) {
		const emailRoot = createRoot(email_address);
		emailRoot.render(<EmailAddress />);
	}
});
