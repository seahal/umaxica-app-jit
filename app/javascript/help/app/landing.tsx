import { createRoot, type Root } from "react-dom/client";
import HelpAppLanding from "../../components/help/app/Landing";

const ROOT_ID = "help-app-react-root";

let root: Root | null = null;

const mount = () => {
	const container = document.getElementById(ROOT_ID);

	if (!container) {
		return;
	}

	if (!root) {
		root = createRoot(container);
	}

	const { dataset } = container;

	root.render(
		<HelpAppLanding
			codeName={dataset.codeName ?? undefined}
			helpServiceUrl={dataset.helpServiceUrl ?? undefined}
			docsServiceUrl={dataset.docsServiceUrl ?? undefined}
			newsServiceUrl={dataset.newsServiceUrl ?? undefined}
		/>,
	);
};

const unmount = () => {
	if (root) {
		root.unmount();
		root = null;
	}
};

const registerTurboEvents = () => {
	document.addEventListener("turbo:load", mount);
	document.addEventListener("turbo:before-render", unmount);
};

const unregisterTurboEvents = () => {
	document.removeEventListener("turbo:load", mount);
	document.removeEventListener("turbo:before-render", unmount);
};

if (document.readyState === "loading") {
	document.addEventListener("DOMContentLoaded", mount);
	document.addEventListener("DOMContentLoaded", registerTurboEvents, {
		once: true,
	});
} else {
	mount();
	registerTurboEvents();
}

if (import.meta && import.meta.hot) {
	import.meta.hot.dispose(() => {
		unregisterTurboEvents();
		unmount();
	});
}
