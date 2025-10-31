export const DOCS_APP_DEFAULT_ORIGIN = "http://docs.app.localhost";

/**
 * Resolves fully-qualified URLs for the docs app surface.
 */
export function resolveDocsAppUrl(path = "/"): URL {
	return new URL(path, DOCS_APP_DEFAULT_ORIGIN);
}

/**
 * Reads hydration props from the docs app container dataset.
 */
const docsAppHostname = new URL(DOCS_APP_DEFAULT_ORIGIN).hostname;

export function readDocsAppProps(
	element: HTMLElement | null,
): Record<string, string> {
	if (!element) {
		return {};
	}

	const { dataset } = element;

	return {
		codeName: dataset.codeName ?? "",
		docsServiceUrl: dataset.docsServiceUrl ?? "",
		helpServiceUrl: dataset.helpServiceUrl ?? "",
		newsServiceUrl: dataset.newsServiceUrl ?? "",
	};
}

type WindowLike = {
	location?: Location;
	addEventListener?: Window["addEventListener"];
	alert?: (message: string) => void;
};

export function isDocsAppHost(
	windowLike: WindowLike | undefined = typeof window !== "undefined"
		? window
		: undefined,
): boolean {
	if (!windowLike) {
		return false;
	}

	const { location } = windowLike;

	if (!location) {
		return false;
	}

	try {
		return location.hostname === docsAppHostname;
	} catch {
		return false;
	}
}

export function installDocsAppHostAlert(
	windowLike: WindowLike | undefined = typeof window !== "undefined"
		? window
		: undefined,
): void {
	if (!windowLike?.addEventListener) {
		return;
	}

	if (!isDocsAppHost(windowLike)) {
		return;
	}

	windowLike.addEventListener("DOMContentLoaded", () => {
		windowLike.alert?.("docs");
	});
}

installDocsAppHostAlert();
