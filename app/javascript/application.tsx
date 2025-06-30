import { createRoot } from "react-dom/client";
import App from "./App";
import HelloWorld from "./components/HelloWorld";

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
	}
});
