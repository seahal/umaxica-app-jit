import { jsx as _jsx } from "hono/jsx/jsx-runtime";
import { Hono } from 'hono';
import { renderer } from './renderer';
const app = new Hono();
app.use(renderer);
app.get('/', (c) => {
    return c.render(_jsx("h1", { children: "Hello!" }));
});
export default app;
