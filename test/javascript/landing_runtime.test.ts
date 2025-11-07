import { afterEach, describe, expect, mock, test } from "bun:test";
import { createElement } from "react";

type Listener = (...args: unknown[]) => void;

type DocumentStubOptions = {
	id: string;
	readyState: "loading" | "complete";
	dataset?: Record<string, string>;
};

type DocumentStub = {
	readyState: string;
	getElementById: (id: string) => { dataset: Record<string, string> } | null;
	addEventListener: (
		event: string,
		handler: Listener,
		options?: unknown,
	) => void;
	removeEventListener: (event: string, handler: Listener) => void;
};

type ListenerMap = Record<string, Listener[]>;

const originalDocument = (globalThis as { document?: Document }).document;
const originalWindow = (globalThis as { window?: unknown }).window;

afterEach(() => {
	if (originalDocument === undefined) {
		delete (globalThis as { document?: Document }).document;
	} else {
		(globalThis as { document?: Document }).document = originalDocument;
	}

	if (originalWindow === undefined) {
		delete (globalThis as { window?: unknown }).window;
	} else {
		(globalThis as { window?: unknown }).window = originalWindow;
	}

	mock.restore();
});

const createReactAriaStub = () => {
	const renderChildren = (children: unknown) => {
		if (typeof children === "function") {
			return children({ isSelected: false });
		}

		return children ?? null;
	};

	const asTag =
		(tag: keyof JSX.IntrinsicElements, droppedProps: string[] = []) =>
		(props: Record<string, unknown> = {}) => {
			const { children, className, ...rest } = props;
			const resolvedClassName =
				typeof className === "function"
					? className({ isSelected: false })
					: className;

			const filteredRest = Object.fromEntries(
				Object.entries(rest).filter(
					([key]) => !droppedProps.includes(key as string),
				),
			);

			return createElement(
				tag,
				{ ...filteredRest, className: resolvedClassName },
				renderChildren(children),
			);
		};

	const buttonLike = (props: Record<string, unknown> = {}) => {
		const { children, onPress, ...rest } = props;
		return createElement(
			"button",
			{ ...rest, onClick: onPress },
			renderChildren(children),
		);
	};

	const linkLike = (props: Record<string, unknown> = {}) => {
		const { children, href, className, ...rest } = props;
		const resolvedClassName =
			typeof className === "function"
				? className({ isSelected: false })
				: className;
		return createElement(
			"a",
			{ ...rest, href, className: resolvedClassName },
			renderChildren(children),
		);
	};

	const inputLike = (props: Record<string, unknown> = {}) => {
		const { children, ...rest } = props;
		return createElement("input", rest, renderChildren(children));
	};

	return {
		Button: buttonLike,
		Group: asTag("div"),
		Input: inputLike,
		Label: asTag("label"),
		Link: linkLike,
		SearchField: asTag("form", ["defaultValue"]),
		Tab: asTag("div", ["id"]),
		TabList: asTag("div"),
		TabPanel: asTag("div"),
		Tabs: asTag("div", ["defaultSelectedKey"]),
		Tooltip: asTag("div"),
		TooltipTrigger: asTag("div"),
		Separator: asTag("hr"),
		ToggleButton: asTag("button", ["defaultSelected"]),
	};
};

const installReactAriaStub = () => {
	mock.module("react-aria-components", () => createReactAriaStub());
};

const applyWindowStub = () => {
	(globalThis as { window?: any }).window = {
		location: { pathname: "/current" },
		innerHeight: 1080,
		scrollTo: () => {},
		alert: () => {},
		open: () => ({}),
	};
};

const createDocumentStub = (
	options: DocumentStubOptions,
): {
	documentStub: DocumentStub;
	listeners: ListenerMap;
	container: { dataset: Record<string, string> };
} => {
	const listeners: ListenerMap = {};
	const container = { dataset: options.dataset ?? {} };

	const documentStub: DocumentStub = {
		readyState: options.readyState,
		getElementById: (id: string) => (id === options.id ? container : null),
		addEventListener: (event: string, handler: Listener) => {
			(listeners[event] ??= []).push(handler);
		},
		removeEventListener: (event: string, handler: Listener) => {
			const entries = listeners[event];
			if (!entries) return;
			listeners[event] = entries.filter((candidate) => candidate !== handler);
		},
	};

	return { documentStub, listeners, container };
};

const setupReactDomMock = () => {
	const containers: unknown[] = [];
	const renderCalls: unknown[] = [];
	const unmountCalls: unknown[] = [];

	mock.module("react-dom/client", () => ({
		createRoot: (container: unknown) => {
			containers.push(container);
			return {
				render: (element: unknown) => {
					renderCalls.push(element);
				},
				unmount: () => {
					unmountCalls.push(container);
				},
			};
		},
	}));

	return { containers, renderCalls, unmountCalls };
};

describe("root landing entrypoint", () => {
	test("mounts landing view when document is ready", async () => {
		installReactAriaStub();
		applyWindowStub();
		const { containers, renderCalls, unmountCalls } = setupReactDomMock();
		const { documentStub, listeners, container } = createDocumentStub({
			id: "root-app-react-root",
			readyState: "complete",
			dataset: {
				codeName: "Atlas",
				rootServiceUrl: "https://app.example",
				docsServiceUrl: "https://docs.example",
				helpServiceUrl: "https://help.example",
				newsServiceUrl: "https://news.example",
			},
		});

		(globalThis as { document?: Document }).document =
			documentStub as unknown as Document;

		await import("../../app/javascript/root/app/landing.tsx");

		expect(containers[0]).toBe(container);
		const rendered = renderCalls[0] as { props: Record<string, unknown> };
		expect(rendered.props.codeName).toBe("Atlas");
		expect(rendered.props.rootServiceUrl).toBe("https://app.example");
		expect(rendered.props.docsServiceUrl).toBe("https://docs.example");
		expect(rendered.props.helpServiceUrl).toBe("https://help.example");
		expect(rendered.props.newsServiceUrl).toBe("https://news.example");
		expect(listeners["turbo:load"]?.length).toBe(1);
		expect(listeners["turbo:before-render"]?.length).toBe(1);
		expect(unmountCalls.length).toBe(0);
	});
});

describe("help landing entrypoints", () => {
	test("help app landing hydrates component props from dataset", async () => {
		installReactAriaStub();
		applyWindowStub();
		const { containers, renderCalls } = setupReactDomMock();
		const { documentStub, listeners, container } = createDocumentStub({
			id: "help-app-react-root",
			readyState: "complete",
			dataset: {
				codeName: "Harbor",
				helpServiceUrl: "https://help.example",
				docsServiceUrl: "https://docs.example",
				newsServiceUrl: "https://news.example",
			},
		});

		(globalThis as { document?: Document }).document =
			documentStub as unknown as Document;

		await import("../../app/javascript/help/app/landing.tsx");

		expect(containers[0]).toBe(container);
		const rendered = renderCalls[0] as { props: Record<string, unknown> };
		expect(rendered.props.codeName).toBe("Harbor");
		expect(rendered.props.helpServiceUrl).toBe("https://help.example");
		expect(rendered.props.docsServiceUrl).toBe("https://docs.example");
		expect(rendered.props.newsServiceUrl).toBe("https://news.example");
		expect(listeners["turbo:load"]?.length).toBe(1);
		expect(listeners["turbo:before-render"]?.length).toBe(1);
	});

	test("help com landing mounts when container exists", async () => {
		installReactAriaStub();
		applyWindowStub();
		const { containers, renderCalls } = setupReactDomMock();
		const { documentStub, listeners, container } = createDocumentStub({
			id: "help-com-react-root",
			readyState: "complete",
		});

		(globalThis as { document?: Document }).document =
			documentStub as unknown as Document;

		await import("../../app/javascript/help/com/landing.tsx");

		expect(containers[0]).toBe(container);
		expect(renderCalls.length).toBe(1);
		expect(listeners["turbo:load"]?.length).toBe(1);
		expect(listeners["turbo:before-render"]?.length).toBe(1);
	});
});
