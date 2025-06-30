import { createRoot } from "react-dom/client";
import App from "./App";
import HelloWorld from "./components/HelloWorld";
=======
import App from "./components/common/App";
import EmailAddress from "./components/www/app/email_address";
>>>>>>> feature

document.addEventListener("DOMContentLoaded", () => {
	const container = document.getElementById("react-root");
	if (container) {
		const root = createRoot(container);
		root.render(<App />);
	}

	const helloWorldContainer = document.getElementById("hello-world-root");
	if (helloWorldContainer) {
		const helloWorldRoot = createRoot(helloWorldContainer);
		helloWorldRoot.render(<HelloWorld />);
=======
	const email_address = document.getElementById("email_address");
	if (email_address) {
		const emailRoot = createRoot(email_address);
		emailRoot.render(<EmailAddress />);
>>>>>>> feature
	}
});
