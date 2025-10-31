export const HELP_ORG_DEFAULT_ORIGIN = "http://help.org.localhost";

/**
 * Builds a fully qualified URL for the help org surface.
 * Accepts relative paths (defaulting to the root) so callers and tests
 * can share the same origin resolver without repeating constants.
 */
export function resolveHelpOrgUrl(path = "/"): URL {
	return new URL(path, HELP_ORG_DEFAULT_ORIGIN);
}

/**
 * Extracts dataset-backed props from a container element so the React shell
 * can be hydrated both in production and during tests.
 */
export function readHelpOrgProps(
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
