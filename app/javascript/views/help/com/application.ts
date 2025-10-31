export const HELP_COM_DEFAULT_ORIGIN = "http://help.com.localhost";

/**
 * Returns a fully-qualified URL for the corporate help surface using its
 * default origin. Relative paths default to the root.
 */
export function resolveHelpComUrl(path = "/"): URL {
	return new URL(path, HELP_COM_DEFAULT_ORIGIN);
}

/**
 * Extracts data attributes that hydrate the corporate help React shell.
 * Falls back to empty strings when attributes are not provided.
 */
export function readHelpComProps(
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
