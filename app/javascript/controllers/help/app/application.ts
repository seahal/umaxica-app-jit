export const HELP_APP_DEFAULT_ORIGIN = "http://help.app.localhost";

/**
 * Resolves absolute URLs for the help service surface so callers can pass
 * relative paths (defaulting to "/") without repeating origin constants.
 */
export function resolveHelpAppUrl(path = "/"): URL {
	return new URL(path, HELP_APP_DEFAULT_ORIGIN);
}

/**
 * Pulls hydration props from the help service container element. The dataset
 * mirrors the values written by the Rails view and keeps tests deterministic.
 */
export function readHelpAppProps(
	element: HTMLElement | null,
): Record<string, string> {
	if (!element) {
		return {};
	}

	const { dataset } = element;

	return {
		codeName: dataset.codeName ?? "",
		helpServiceUrl: dataset.helpServiceUrl ?? "",
		docsServiceUrl: dataset.docsServiceUrl ?? "",
		newsServiceUrl: dataset.newsServiceUrl ?? "",
	};
}
