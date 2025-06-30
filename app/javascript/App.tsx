import type React from "react";
import { useState } from "react";

const App: React.FC = () => {
	const [count, setCount] = useState(0);

	return (
		<div
			style={{
				padding: "20px",
				border: "2px solid #007bff",
				borderRadius: "8px",
				margin: "20px 0",
				backgroundColor: "#f8f9fa",
			}}
		>
			<h2>🎉 React is working with Bun!</h2>
			<div style={{ margin: "20px 0" }}>
				<p>Counter: {count}</p>
				<button
					type="button"
					onClick={() => setCount(count + 1)}
					style={{
						padding: "10px 20px",
						backgroundColor: "#007bff",
						color: "white",
						border: "none",
						borderRadius: "4px",
						cursor: "pointer",
						marginRight: "10px",
					}}
				>
					Increment
				</button>
				<button
					type="button"
					onClick={() => setCount(0)}
					style={{
						padding: "10px 20px",
						backgroundColor: "#6c757d",
						color: "white",
						border: "none",
						borderRadius: "4px",
						cursor: "pointer",
					}}
				>
					Reset
				</button>
			</div>
			<p style={{ fontSize: "14px", color: "#6c757d" }}>
				このコンポーネントは Rails + Bun + React で動作しています3
			</p>
		</div>
	);
};

export default App;
