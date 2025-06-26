import type { FC } from "hono/jsx";

const Layout: FC = (props, title = undefined) => {
	return (
		<html lang="ja">
			<head>
				<title>Umaxica | {title}</title>
			</head>
			<body>
				<header>
					<h1>Umaxica(com, edge)</h1>
				</header>
				<hr />
				{props.children}
				<hr />
				<footer>
					<p>© umaxica</p>
				</footer>
			</body>
		</html>
	);
};

export default Layout;
