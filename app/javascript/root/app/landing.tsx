import { createRoot, type Root } from "react-dom/client";
import RootAppLanding from "../../components/root/app/Landing";
import { readRootAppProps } from "../../views/root/app/application";

const ROOT_ID = "root-app-react-root";

let root: Root | null = null;

const mount = () => {
	const container = document.getElementById(ROOT_ID);

	if (!container) {
		return;
	}

	if (!root) {
		root = createRoot(container);
	}

	const {
		codeName,
		rootServiceUrl,
		docsServiceUrl,
		helpServiceUrl,
		newsServiceUrl,
	} = readRootAppProps(container);

	root.render(
		<RootAppLanding
			codeName={codeName}
			rootServiceUrl={rootServiceUrl}
			docsServiceUrl={docsServiceUrl}
			helpServiceUrl={helpServiceUrl}
			newsServiceUrl={newsServiceUrl}
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
