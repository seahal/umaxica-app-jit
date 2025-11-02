import {describe, expect, test} from "bun:test";

type SurfaceScenario = {
	name: string;
	modulePath: string;
	originConst: string;
	expectedOrigin: string;
	resolveExport: string;
	readExport: string;
	dataset: Record<string, string>;
	expectedProps: Record<string, string>;
};

const surfaces: SurfaceScenario[] = [
	{
		name: "root app",
		modulePath: "../../../app/javascript/views/root/app/application.ts",
		originConst: "ROOT_APP_DEFAULT_ORIGIN",
		expectedOrigin: "http://app.localhost",
		resolveExport: "resolveRootAppUrl",
		readExport: "readRootAppProps",
		dataset: {
			codeName: "Atlas",
			rootServiceUrl: "https://app.example",
			docsServiceUrl: "https://docs.example",
		},
		expectedProps: {
			codeName: "Atlas",
			rootServiceUrl: "https://app.example",
			docsServiceUrl: "https://docs.example",
			helpServiceUrl: "",
			newsServiceUrl: "",
		},
	},
	{
		name: "root com",
		modulePath: "../../../app/javascript/views/root/com/application.ts",
		originConst: "ROOT_COM_DEFAULT_ORIGIN",
		expectedOrigin: "http://com.localhost",
		resolveExport: "resolveRootComUrl",
		readExport: "readRootComProps",
		dataset: {
			codeName: "Beacon",
			rootServiceUrl: "https://app.example",
			helpServiceUrl: "https://help.example",
		},
		expectedProps: {
			codeName: "Beacon",
			rootServiceUrl: "https://app.example",
			docsServiceUrl: "",
			helpServiceUrl: "https://help.example",
			newsServiceUrl: "",
		},
	},
	{
		name: "root org",
		modulePath: "../../../app/javascript/views/root/org/application.ts",
		originConst: "ROOT_ORG_DEFAULT_ORIGIN",
		expectedOrigin: "http://org.localhost",
		resolveExport: "resolveRootOrgUrl",
		readExport: "readRootOrgProps",
		dataset: {
			codeName: "Cipher",
			rootServiceUrl: "https://staff.example",
			newsServiceUrl: "https://news.example",
		},
		expectedProps: {
			codeName: "Cipher",
			rootServiceUrl: "https://staff.example",
			docsServiceUrl: "",
			helpServiceUrl: "",
			newsServiceUrl: "https://news.example",
		},
	},
	{
		name: "docs app",
		modulePath: "../../../app/javascript/views/docs/app/application.ts",
		originConst: "DOCS_APP_DEFAULT_ORIGIN",
		expectedOrigin: "http://docs.app.localhost",
		resolveExport: "resolveDocsAppUrl",
		readExport: "readDocsAppProps",
		dataset: {
			codeName: "Delta",
			docsServiceUrl: "https://docs.example",
		},
		expectedProps: {
			codeName: "Delta",
			docsServiceUrl: "https://docs.example",
			helpServiceUrl: "",
			newsServiceUrl: "",
		},
	},
	{
		name: "docs com",
		modulePath: "../../../app/javascript/views/docs/com/application.ts",
		originConst: "DOCS_COM_DEFAULT_ORIGIN",
		expectedOrigin: "http://docs.com.localhost",
		resolveExport: "resolveDocsComUrl",
		readExport: "readDocsComProps",
		dataset: {
			codeName: "Echo",
			helpServiceUrl: "https://help.example",
		},
		expectedProps: {
			codeName: "Echo",
			docsServiceUrl: "",
			helpServiceUrl: "https://help.example",
			newsServiceUrl: "",
		},
	},
	{
		name: "docs org",
		modulePath: "../../../app/javascript/views/docs/org/application.ts",
		originConst: "DOCS_ORG_DEFAULT_ORIGIN",
		expectedOrigin: "http://docs.org.localhost",
		resolveExport: "resolveDocsOrgUrl",
		readExport: "readDocsOrgProps",
		dataset: {
			codeName: "Foxtrot",
			newsServiceUrl: "https://news.example",
		},
		expectedProps: {
			codeName: "Foxtrot",
			docsServiceUrl: "",
			helpServiceUrl: "",
			newsServiceUrl: "https://news.example",
		},
	},
	{
		name: "help app",
		modulePath: "../../../app/javascript/views/help/app/application.ts",
		originConst: "HELP_APP_DEFAULT_ORIGIN",
		expectedOrigin: "http://help.app.localhost",
		resolveExport: "resolveHelpAppUrl",
		readExport: "readHelpAppProps",
		dataset: {
			codeName: "Galaxy",
			helpServiceUrl: "https://help.example",
		},
		expectedProps: {
			codeName: "Galaxy",
			helpServiceUrl: "https://help.example",
			docsServiceUrl: "",
			newsServiceUrl: "",
		},
	},
	{
		name: "help com",
		modulePath: "../../../app/javascript/views/help/com/application.ts",
		originConst: "HELP_COM_DEFAULT_ORIGIN",
		expectedOrigin: "http://help.com.localhost",
		resolveExport: "resolveHelpComUrl",
		readExport: "readHelpComProps",
		dataset: {
			codeName: "Harbor",
			docsServiceUrl: "https://docs.example",
		},
		expectedProps: {
			codeName: "Harbor",
			helpServiceUrl: "",
			docsServiceUrl: "https://docs.example",
			newsServiceUrl: "",
		},
	},
	{
		name: "help org",
		modulePath: "../../../app/javascript/views/help/org/application.ts",
		originConst: "HELP_ORG_DEFAULT_ORIGIN",
		expectedOrigin: "http://help.org.localhost",
		resolveExport: "resolveHelpOrgUrl",
		readExport: "readHelpOrgProps",
		dataset: {
			codeName: "Infinity",
			newsServiceUrl: "https://news.example",
		},
		expectedProps: {
			codeName: "Infinity",
			helpServiceUrl: "",
			docsServiceUrl: "",
			newsServiceUrl: "https://news.example",
		},
	},
	{
		name: "news app",
		modulePath: "../../../app/javascript/views/news/app/application.ts",
		originConst: "NEWS_APP_DEFAULT_ORIGIN",
		expectedOrigin: "http://news.app.localhost",
		resolveExport: "resolveNewsAppUrl",
		readExport: "readNewsAppProps",
		dataset: {
			codeName: "Jupiter",
			newsServiceUrl: "https://news.example",
		},
		expectedProps: {
			codeName: "Jupiter",
			newsServiceUrl: "https://news.example",
			docsServiceUrl: "",
			helpServiceUrl: "",
		},
	},
	{
		name: "news com",
		modulePath: "../../../app/javascript/views/news/com/application.ts",
		originConst: "NEWS_COM_DEFAULT_ORIGIN",
		expectedOrigin: "http://news.com.localhost",
		resolveExport: "resolveNewsComUrl",
		readExport: "readNewsComProps",
		dataset: {
			codeName: "Kinetic",
			helpServiceUrl: "https://help.example",
		},
		expectedProps: {
			codeName: "Kinetic",
			newsServiceUrl: "",
			docsServiceUrl: "",
			helpServiceUrl: "https://help.example",
		},
	},
	{
		name: "news org",
		modulePath: "../../../app/javascript/views/news/org/application.ts",
		originConst: "NEWS_ORG_DEFAULT_ORIGIN",
		expectedOrigin: "http://news.org.localhost",
		resolveExport: "resolveNewsOrgUrl",
		readExport: "readNewsOrgProps",
		dataset: {
			codeName: "Luminous",
			docsServiceUrl: "https://docs.example",
		},
		expectedProps: {
			codeName: "Luminous",
			newsServiceUrl: "",
			docsServiceUrl: "https://docs.example",
			helpServiceUrl: "",
		},
	},
	{
		name: "sign app",
		modulePath: "../../../app/javascript/views/sign/app/application.ts",
		originConst: "SIGN_APP_DEFAULT_ORIGIN",
		expectedOrigin: "http://sign.app.localhost",
		resolveExport: "resolveSignAppUrl",
		readExport: "readSignAppProps",
		dataset: {
			codeName: "Monarch",
			signServiceUrl: "https://sign.example",
		},
		expectedProps: {
			codeName: "Monarch",
			signServiceUrl: "https://sign.example",
			helpServiceUrl: "",
		},
	},
	{
		name: "sign org",
		modulePath: "../../../app/javascript/views/sign/org/application.ts",
		originConst: "SIGN_ORG_DEFAULT_ORIGIN",
		expectedOrigin: "http://sign.org.localhost",
		resolveExport: "resolveSignOrgUrl",
		readExport: "readSignOrgProps",
		dataset: {
			codeName: "Nebula",
			helpServiceUrl: "https://help.example",
		},
		expectedProps: {
			codeName: "Nebula",
			signServiceUrl: "",
			helpServiceUrl: "https://help.example",
		},
	},
	{
		name: "www app",
		modulePath: "../../../app/javascript/views/www/app/application.ts",
		originConst: "WWW_APP_DEFAULT_ORIGIN",
		expectedOrigin: "http://www.app.localhost",
		resolveExport: "resolveWwwAppUrl",
		readExport: "readWwwAppProps",
		dataset: {
			codeName: "Orbit",
			wwwServiceUrl: "https://www.example",
			docsServiceUrl: "https://docs.example",
		},
		expectedProps: {
			codeName: "Orbit",
			wwwServiceUrl: "https://www.example",
			docsServiceUrl: "https://docs.example",
			helpServiceUrl: "",
			newsServiceUrl: "",
		},
	},
	{
		name: "www com",
		modulePath: "../../../app/javascript/views/www/com/application.ts",
		originConst: "SIGN_ORG_DEFAULT_ORIGIN",
		expectedOrigin: "http://www.com.localhost",
		resolveExport: "resolveSignOrgUrl",
		readExport: "readSignOrgProps",
		dataset: {
			codeName: "Pulse",
			signServiceUrl: "https://sign.example",
		},
		expectedProps: {
			codeName: "Pulse",
			signServiceUrl: "https://sign.example",
			helpServiceUrl: "",
		},
	},
	{
		name: "www org",
		modulePath: "../../../app/javascript/views/www/org/application.ts",
		originConst: "SIGN_ORG_DEFAULT_ORIGIN",
		expectedOrigin: "http://www.org.localhost",
		resolveExport: "resolveSignOrgUrl",
		readExport: "readSignOrgProps",
		dataset: {
			codeName: "Quasar",
			helpServiceUrl: "https://help.example",
		},
		expectedProps: {
			codeName: "Quasar",
			signServiceUrl: "",
			helpServiceUrl: "https://help.example",
		},
	},
];

describe("surface view modules", () => {
	for (const surface of surfaces) {
		test(`${surface.name} resolves URLs relative to the default origin`, async () => {
			const module = (await import(surface.modulePath)) as Record<string, unknown>;
			expect(module[surface.originConst]).toBe(surface.expectedOrigin);

			const resolve = module[surface.resolveExport] as (path?: string) => URL;
			expect(resolve().href).toBe(`${surface.expectedOrigin}/`);
			expect(resolve("/status").href).toBe(`${surface.expectedOrigin}/status`);
			expect(resolve("status").href).toBe(`${surface.expectedOrigin}/status`);
		});

		test(`${surface.name} reads hydration props from dataset entries`, async () => {
			const module = (await import(surface.modulePath)) as Record<string, unknown>;
			const read = module[surface.readExport] as (
				element: HTMLElement | null,
			) => Record<string, string>;

			expect(read(null)).toEqual({});

			const element = {
				dataset: surface.dataset,
			} as unknown as HTMLElement;

			expect(read(element)).toEqual(surface.expectedProps);
		});
	}
});

const docsAppModulePath = "../../../app/javascript/views/docs/app/application.ts";

describe("docs app host detection", () => {
	test("identifies docs host reliably", async () => {
		const { isDocsAppHost } = await import(docsAppModulePath);

		expect(isDocsAppHost(undefined)).toBe(false);
		expect(isDocsAppHost({} as any)).toBe(false);
		expect(isDocsAppHost({ location: undefined } as any)).toBe(false);
		expect(
			isDocsAppHost({
				location: { hostname: "docs.app.localhost" } as Location,
			}),
		).toBe(true);
		expect(
			isDocsAppHost({
				location: { hostname: "example.com" } as Location,
			}),
		).toBe(false);
	});

	test("installs DOMContentLoaded alert only when running on docs host", async () => {
		const { installDocsAppHostAlert } = await import(
			`${docsAppModulePath}?alert-test=1`
		);

		const alerts: string[] = [];
		const listeners: Record<string, Array<() => void>> = {};

		const windowLike = {
			location: { hostname: "docs.app.localhost" } as Location,
			addEventListener: (event: string, handler: () => void) => {
				(listeners[event] ??= []).push(handler);
			},
			alert: (message: string) => {
				alerts.push(message);
			},
		};

		installDocsAppHostAlert(windowLike);

		expect(listeners.DOMContentLoaded?.length).toBe(1);
		listeners.DOMContentLoaded?.[0]?.();
		expect(alerts).toEqual(["docs"]);

		const mismatchedListeners: Record<string, Array<() => void>> = {};
		installDocsAppHostAlert({
			location: { hostname: "example.com" } as Location,
			addEventListener: (event: string, handler: () => void) => {
				(mismatchedListeners[event] ??= []).push(handler);
			},
			alert: () => {
				throw new Error("should not alert on non-docs host");
			},
		});
		expect(mismatchedListeners.DOMContentLoaded).toBeUndefined();

		expect(() =>
			installDocsAppHostAlert({
				location: { hostname: "docs.app.localhost" } as Location,
			} as any),
		).not.toThrow();
	});
});
