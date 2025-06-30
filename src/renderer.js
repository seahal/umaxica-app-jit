import { jsx as _jsx, jsxs as _jsxs } from "hono/jsx/jsx-runtime";
import { jsxRenderer } from 'hono/jsx-renderer';
import { Link, ViteClient } from 'vite-ssr-components/hono';
export const renderer = jsxRenderer(({ children }) => {
    return (_jsxs("html", { children: [_jsxs("head", { children: [_jsx(ViteClient, {}), _jsx(Link, { href: "/src/style.css", rel: "stylesheet" })] }), _jsx("body", { children: children })] }));
});
