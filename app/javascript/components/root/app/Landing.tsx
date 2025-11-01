import type { FC, ReactNode } from "react";
import {
	Button,
	Group,
	Input,
	Label,
	Link,
	SearchField,
	Tab,
	TabList,
	TabPanel,
	Tabs,
	Tooltip,
	TooltipTrigger,
} from "react-aria-components";

type RootAppLandingProps = {
	codeName?: string;
	rootServiceUrl?: string;
	docsServiceUrl?: string;
	helpServiceUrl?: string;
	newsServiceUrl?: string;
};

type NavigationLink = {
	href: string;
	label: string;
};

type ShortcutLink = {
	href: string;
	icon: string;
	label: string;
};

type HighlightMetric = {
	title: string;
	value: string;
	description: string;
};

type FeatureTab = {
	id: string;
	name: string;
	description: string;
	qualities: string[];
};

type ResourceCard = {
	title: string;
	description: string;
	category: string;
	actionLabel: string;
	actionHref: string;
	icon: ReactNode;
};

type Testimonial = {
	name: string;
	role: string;
	message: string;
};

const navigationLinks: NavigationLink[] = [
	{ href: "#solutions", label: "ソリューション" },
	{ href: "#features", label: "製品機能" },
	{ href: "#resources", label: "リソース" },
	{ href: "#stories", label: "ストーリー" },
];

const shortcutLinks: ShortcutLink[] = [
	{ href: "#", icon: "✨", label: "ワークスペースを作成" },
	{ href: "#", icon: "🧭", label: "導入ガイド" },
	{ href: "#", icon: "📺", label: "ライブデモを見る" },
];

const highlightMetrics: HighlightMetric[] = [
	{
		title: "総合アクティブ",
		value: "128K+",
		description: "24時間以内にアクティブなワークスペース数",
	},
	{
		title: "応答レイテンシ",
		value: "48ms",
		description: "平均レスポンス。グローバル POP で高速に配信",
	},
	{
		title: "アクセシビリティ監査",
		value: "AAA",
		description: "React Aria と Tailwind の組み合わせで達成",
	},
];

const featureTabs: FeatureTab[] = [
	{
		id: "experience",
		name: "体験設計",
		description:
			"リアルタイムな共同編集と、参加者ごとのタイムラインビューでコミュニティの熱量を可視化します。",
		qualities: [
			"React Aria ベースの UI でキーボード & スクリーンリーダー完全対応。",
			"Tailwind プリセットでブランドと調和したレスポンシブデザイン。",
			"セクション単位で切り替えられるライブモデレーション。",
		],
	},
	{
		id: "insights",
		name: "インサイト",
		description:
			"投稿やリアクションを語彙クラスタでグルーピングし、提案アクションを自動生成します。",
		qualities: [
			"1.5 億件のイベントをもとにしたベースラインとアラートを提供。",
			"ニュースレター・SNS 連携で最適な配信時間を提案。",
			"メンバーセグメントごとの健全性スコアを自動出力。",
		],
	},
	{
		id: "automation",
		name: "自動化",
		description:
			"ワークフローのテンプレートとマクロを組み合わせ、手動作業を 40% 削減します。",
		qualities: [
			"Webhook と Edge Functions による高速オーケストレーション。",
			"Slack・Discord・メールと双方向同期。",
			"ステージング環境から本番へのプロモートは 1 クリック。",
		],
	},
];

const resourceCards: ResourceCard[] = [
	{
		title: "エンゲージメントダッシュボード",
		description:
			"セッション時間・コメント・CV 率をまとめたテンプレート。React Aria コンポーネントの活用例付き。",
		category: "テンプレート",
		actionLabel: "テンプレートを複製",
		actionHref: "#",
		icon: (
			<svg
				viewBox="0 0 24 24"
				aria-hidden="true"
				className="h-10 w-10 text-indigo-300"
			>
				<path
					fill="currentColor"
					d="M5 3a2 2 0 00-2 2v4h2V5h4V3H5zm10 0v2h4v4h2V5a2 2 0 00-2-2h-4zM3 15v4a2 2 0 002 2h4v-2H5v-4H3zm16 4h-4v2h4a2 2 0 002-2v-4h-2v4z"
				/>
				<path fill="currentColor" d="M7 7h10v10H7z" opacity={0.6} />
			</svg>
		),
	},
	{
		title: "ローンチプレイブック",
		description:
			"初回発表から 30 日間のアクティビティプラン。通知・メール・スペース配信まで網羅。",
		category: "ガイド",
		actionLabel: "PDF をダウンロード",
		actionHref: "#",
		icon: (
			<svg
				viewBox="0 0 24 24"
				aria-hidden="true"
				className="h-10 w-10 text-sky-300"
			>
				<path
					fill="currentColor"
					d="M12 2l7 4v6c0 5-3.5 9.74-7 10-3.5-.26-7-5-7-10V6l7-4z"
				/>
				<path
					fill="currentColor"
					d="M11 7h2v6h-2zm0 8h2v2h-2z"
					className="text-slate-900"
				/>
			</svg>
		),
	},
	{
		title: "アクセシビリティレビューツールキット",
		description:
			"React Aria での設計チェックリストと、Tailwind のトークン活用サンプルを収録。",
		category: "アクセシビリティ",
		actionLabel: "チェックリストを見る",
		actionHref: "#",
		icon: (
			<svg
				viewBox="0 0 24 24"
				aria-hidden="true"
				className="h-10 w-10 text-teal-300"
			>
				<path fill="currentColor" d="M4 4h16v2H4zm0 6h16v2H4zm0 6h10v2H4z" />
				<path
					fill="currentColor"
					d="M18.5 12l2.5 2.5-5.5 5.5-2.5-2.5z"
					opacity={0.8}
				/>
			</svg>
		),
	},
];

const testimonials: Testimonial[] = [
	{
		name: "Aya Nakamura",
		role: "Community Architect, Flux Studio",
		message:
			"「React Aria コンポーネントを Tailwind プリセットと組み合わせることで、チーム全員がアクセシブルな UI を高速に実装できています。」",
	},
	{
		name: "Jordan Lee",
		role: "Head of Members, Marathon Collective",
		message:
			"「各リージョンの参加者がいつでも同じ体験を得られるので、ワークスペースの立ち上げに躊躇がなくなりました。」",
	},
];

const Header: FC<
	RootAppLandingProps & {
		navigation: NavigationLink[];
		shortcuts: ShortcutLink[];
	}
> = ({ codeName = "Umaxica", navigation, shortcuts, docsServiceUrl = "" }) => {
	const docsHref = docsServiceUrl ? `https://${docsServiceUrl}` : "#";

	return (
		<header className="sticky top-0 z-40 border-b border-white/10 bg-slate-950/70 backdrop-blur-xl">
			<div className="mx-auto flex flex-wrap items-center justify-between gap-4 px-4 py-4 sm:px-6 lg:px-10">
				<Link
					href="/"
					className="flex items-center gap-3 rounded-full border border-white/10 bg-white/5 px-4 py-2 text-sm font-semibold text-white transition hover:border-white/20 hover:bg-white/10 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-300"
				>
					<span className="inline-flex h-9 w-9 items-center justify-center rounded-full bg-gradient-to-br from-indigo-500 to-purple-500 text-lg">
						✨
					</span>
					<span>{codeName}</span>
				</Link>

				<nav className="flex flex-1 flex-wrap items-center justify-center gap-3 text-sm text-slate-200 sm:justify-start">
					{navigation.map((item) => (
						<Link
							key={item.href}
							href={item.href}
							className="rounded-full px-3 py-1.5 font-medium transition hover:bg-white/10 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-300"
						>
							{item.label}
						</Link>
					))}
				</nav>

				<div className="flex items-center gap-2">
					{shortcuts.map((shortcut) => (
						<TooltipTrigger delay={300} key={shortcut.label}>
							<Link
								href={shortcut.href}
								className="grid h-10 w-10 place-items-center rounded-full border border-white/10 bg-white/5 text-lg transition hover:border-white/20 hover:bg-white/10 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-300"
							>
								<span aria-hidden>{shortcut.icon}</span>
								<span className="sr-only">{shortcut.label}</span>
							</Link>
							<Tooltip className="rounded-md border border-white/10 bg-slate-900 px-2.5 py-1.5 text-xs text-white shadow-lg shadow-black/30">
								{shortcut.label}
							</Tooltip>
						</TooltipTrigger>
					))}

					<Link
						href={docsHref}
						className="inline-flex items-center gap-2 rounded-full bg-white px-4 py-2 text-sm font-semibold text-slate-900 transition hover:bg-slate-100 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-100"
					>
						<span className="text-xs uppercase tracking-widest text-slate-500">
							Docs
						</span>
					</Link>
				</div>
			</div>
		</header>
	);
};

const Footer: FC<
	Pick<
		RootAppLandingProps,
		| "codeName"
		| "rootServiceUrl"
		| "docsServiceUrl"
		| "helpServiceUrl"
		| "newsServiceUrl"
	>
> = ({
	codeName = "Umaxica",
	rootServiceUrl = "",
	docsServiceUrl = "",
	helpServiceUrl = "",
	newsServiceUrl = "",
}) => {
	const links = [
		{
			label: "プロダクト",
			href: rootServiceUrl ? `https://${rootServiceUrl}` : "#",
		},
		{
			label: "ドキュメント",
			href: docsServiceUrl ? `https://${docsServiceUrl}` : "#",
		},
		{
			label: "ヘルプセンター",
			href: helpServiceUrl ? `https://${helpServiceUrl}` : "#",
		},
		{
			label: "ニュースルーム",
			href: newsServiceUrl ? `https://${newsServiceUrl}` : "#",
		},
	];

	return (
		<footer className="border-t border-white/5 bg-slate-950/80">
			<div className="mx-auto flex flex-col gap-6 px-4 py-10 text-sm text-slate-300 sm:px-6 lg:px-10 lg:flex-row lg:items-center lg:justify-between">
				<div className="space-y-2">
					<p className="text-xs uppercase tracking-[0.35em] text-indigo-200">
						{codeName}
					</p>
					<p className="text-slate-400">
						すべてのコミュニティに、アクセシブルで表現力豊かな体験を。
					</p>
				</div>
				<nav className="flex flex-wrap items-center gap-3 text-xs font-medium uppercase tracking-[0.25em] text-slate-400">
					{links.map((link) => (
						<Link
							key={link.label}
							href={link.href}
							className="rounded-full px-3 py-1 transition hover:bg-white/10 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-300"
						>
							{link.label}
						</Link>
					))}
				</nav>
			</div>
		</footer>
	);
};

const RootAppLanding: FC<RootAppLandingProps> = ({
	codeName = "Umaxica",
	rootServiceUrl = "",
	docsServiceUrl = "",
	helpServiceUrl = "",
	newsServiceUrl = "",
}) => {
	return (
		<div className="relative flex min-h-screen flex-col bg-slate-950 text-slate-50">
			<div
				aria-hidden="true"
				className="pointer-events-none absolute inset-x-0 top-[-12rem] -z-10 h-[30rem] bg-gradient-to-br from-indigo-500 via-purple-500 to-sky-500 opacity-60 blur-3xl"
			/>

			<Header
				codeName={codeName}
				docsServiceUrl={docsServiceUrl}
				navigation={navigationLinks}
				shortcuts={shortcutLinks}
			/>

			<main className="relative mx-auto w-full max-w-7xl flex-1 px-4 pb-24 pt-16 sm:px-6 lg:px-10">
				<section
					id="solutions"
					className="grid gap-12 lg:grid-cols-[1.3fr_1fr] lg:items-start"
				>
					<div className="space-y-8">
						<div className="inline-flex items-center gap-2 rounded-full border border-indigo-400/40 bg-indigo-500/10 px-4 py-1 text-xs font-semibold uppercase tracking-[0.35em] text-indigo-100">
							全体最適のためのクリエイティブツール
						</div>
						<h1 className="text-4xl font-semibold leading-tight text-white sm:text-5xl">
							リアルタイムに進化するコミュニティのための
							<br className="hidden sm:block" />
							フラグシップスペース。
						</h1>
						<p className="max-w-2xl text-base leading-relaxed text-slate-200 sm:text-lg">
							{codeName}
							では React Aria のアクセシビリティと Tailwind
							のスピードを組み合わせ、ローンチ当日から洗練された体験を提供します。メンバーとの信頼関係を築きながら、プロダクトの価値を最短で届けましょう。
						</p>

						<SearchField
							aria-label="ワークスペースを検索"
							onSubmit={() => window.alert("検索機能は現在ベータ準備中です。")}
							className="w-full max-w-xl rounded-full border border-white/10 bg-slate-900/60 p-1 shadow-lg shadow-indigo-500/10 backdrop-blur-xl"
						>
							<Label className="sr-only">ワークスペースを検索</Label>
							<Group className="flex items-center gap-2">
								<span className="inline-flex h-9 w-9 items-center justify-center rounded-full bg-white/10 text-lg">
									🔍
								</span>
								<Input
									className="flex-1 bg-transparent text-sm text-white placeholder:text-slate-400 focus:outline-none"
									placeholder="ワークスペース名やタグラインで検索..."
								/>
								<Button className="rounded-full bg-white px-4 py-2 text-sm font-semibold text-slate-900 transition hover:bg-slate-200 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-200">
									探索する
								</Button>
							</Group>
						</SearchField>

						<div className="flex flex-wrap items-center gap-4 text-xs font-medium uppercase tracking-[0.25em] text-slate-300">
							<span className="rounded-full border border-white/10 px-3 py-1">
								React Aria + Tailwind
							</span>
							<span className="rounded-full border border-white/10 px-3 py-1">
								Edge ready
							</span>
							<span className="rounded-full border border-white/10 px-3 py-1">
								Global CDN
							</span>
						</div>

						<div className="grid gap-5 sm:grid-cols-3">
							{highlightMetrics.map((metric) => (
								<div
									key={metric.title}
									className="rounded-3xl border border-white/10 bg-white/5 p-6 backdrop-blur-xl transition hover:border-white/20 hover:bg-white/10"
								>
									<p className="text-xs font-semibold uppercase tracking-[0.3em] text-indigo-200">
										{metric.title}
									</p>
									<p className="mt-3 text-3xl font-semibold text-white">
										{metric.value}
									</p>
									<p className="mt-2 text-xs text-indigo-100">
										{metric.description}
									</p>
								</div>
							))}
						</div>
					</div>

					<div className="flex flex-col gap-6 rounded-3xl border border-white/10 bg-slate-900/70 p-6 shadow-2xl shadow-indigo-500/20 backdrop-blur-xl">
						<div className="rounded-3xl border border-white/10 bg-slate-950/60 p-6">
							<h2 className="text-sm font-semibold uppercase tracking-[0.3em] text-slate-200">
								ローンチチームの進捗
							</h2>
							<ul className="mt-5 space-y-4 text-sm text-slate-200">
								<li className="flex items-start gap-3 rounded-2xl bg-white/5 p-4">
									<span className="mt-1 text-lg">✅</span>
									<div>
										<p className="font-semibold text-white">
											ヒーローセクションのアクセシビリティ監査が完了
										</p>
										<p className="text-xs text-slate-400">
											ARIA 属性とランドマークの最適化が完了しました。
										</p>
									</div>
								</li>
								<li className="flex items-start gap-3 rounded-2xl bg-white/5 p-4">
									<span className="mt-1 text-lg">⚙️</span>
									<div>
										<p className="font-semibold text-white">
											ステージング配信を Edge 環境へ
										</p>
										<p className="text-xs text-slate-400">
											グローバル POP へのデプロイを 17:00 JST に予定。
										</p>
									</div>
								</li>
								<li className="flex items-start gap-3 rounded-2xl bg-white/5 p-4">
									<span className="mt-1 text-lg">🎙️</span>
									<div>
										<p className="font-semibold text-white">
											ローンチイベントの AMA セッション準備中
										</p>
										<p className="text-xs text-slate-400">
											モデレーター向け台本とテンプレートを Docs で共有済み。
										</p>
									</div>
								</li>
							</ul>
						</div>

						<div className="rounded-3xl border border-white/10 bg-indigo-500/10 p-6 text-indigo-100">
							<p className="text-xs font-semibold uppercase tracking-[0.35em] text-indigo-200">
								今週のハイライト
							</p>
							<p className="mt-3 text-lg font-semibold text-white">
								「マルチリージョンコミュニティを立ち上げるための 7
								ステップ」を新しいテンプレートとして公開しました。
							</p>
							<Link
								href={newsServiceUrl ? `https://${newsServiceUrl}` : "#"}
								className="mt-4 inline-flex items-center text-sm font-semibold text-indigo-100 underline decoration-indigo-300/40 underline-offset-4 transition hover:text-white"
							>
								詳細を読む →
							</Link>
						</div>
					</div>
				</section>

				<section id="features" className="mt-20 space-y-8">
					<header className="space-y-4">
						<h2 className="text-3xl font-semibold text-white sm:text-4xl">
							チーム全員がアクセシブルな体験を設計できるワークベンチ。
						</h2>
						<p className="max-w-3xl text-base text-slate-300 sm:text-lg">
							タブで機能領域を切り替えながら、React Aria
							コンポーネントのサンプルとベストプラクティスを探してみましょう。
						</p>
					</header>

					<Tabs
						defaultSelectedKey={featureTabs[0]?.id}
						className="grid gap-6 lg:grid-cols-[0.9fr_1.1fr]"
					>
						<TabList
							aria-label="製品機能カテゴリ"
							className="flex flex-col gap-3 rounded-3xl border border-white/10 bg-white/5 p-4"
						>
							{featureTabs.map((tab) => (
								<Tab
									key={tab.id}
									id={tab.id}
									className={({ isSelected }) =>
										[
											"rounded-2xl px-4 py-3 text-left text-sm font-semibold transition focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-300",
											isSelected
												? "bg-indigo-500 text-white shadow-lg shadow-indigo-500/40"
												: "text-slate-200 hover:bg-white/10 hover:text-white",
										].join(" ")
									}
								>
									{tab.name}
								</Tab>
							))}
						</TabList>

						{featureTabs.map((tab) => (
							<TabPanel
								key={tab.id}
								id={tab.id}
								className="rounded-3xl border border-white/10 bg-slate-900/60 p-8 shadow-2xl shadow-indigo-500/10 backdrop-blur-lg"
							>
								<div className="space-y-4 text-slate-200">
									<h3 className="text-2xl font-semibold text-white">
										{tab.name}
									</h3>
									<p className="text-sm leading-relaxed">{tab.description}</p>
									<ul className="space-y-3 text-sm">
										{tab.qualities.map((quality) => (
											<li key={quality} className="flex gap-3">
												<span
													className="mt-1 inline-flex h-2 w-2 flex-none rounded-full bg-indigo-400"
													aria-hidden
												/>
												<span>{quality}</span>
											</li>
										))}
									</ul>
									<Button
										onPress={() =>
											window.open(
												docsServiceUrl ? `https://${docsServiceUrl}` : "#",
												"_blank",
											)
										}
										className="mt-6 inline-flex items-center gap-2 rounded-full bg-white px-5 py-2 text-sm font-semibold text-slate-900 transition hover:bg-slate-200 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-200"
									>
										サンプルコード
									</Button>
								</div>
							</TabPanel>
						))}
					</Tabs>
				</section>

				<section
					id="resources"
					className="mt-20 rounded-3xl border border-white/10 bg-gradient-to-br from-indigo-600/20 via-purple-600/20 to-sky-500/20 p-10 shadow-2xl shadow-indigo-500/20"
				>
					<header className="space-y-4 text-white">
						<h2 className="text-3xl font-semibold sm:text-4xl">
							ローンチを成功させるためのキュレーション。
						</h2>
						<p className="max-w-3xl text-base text-indigo-100">
							Tailwind ユーティリティと React Aria
							を組み合わせた最新のスニペットや、実際のキャンペーンで使われているテンプレートをダウンロードできます。
						</p>
					</header>

					<div className="mt-10 grid gap-6 md:grid-cols-3">
						{resourceCards.map((resource) => (
							<div
								key={resource.title}
								className="group flex h-full flex-col justify-between rounded-3xl border border-white/15 bg-slate-950/40 p-6 transition hover:border-white/30 hover:bg-slate-950/60"
							>
								<div className="space-y-4">
									<div className="inline-flex rounded-full border border-white/15 bg-white/10 px-3 py-1 text-xs font-semibold uppercase tracking-[0.3em] text-indigo-200">
										{resource.category}
									</div>
									<div>{resource.icon}</div>
									<h3 className="text-lg font-semibold text-white">
										{resource.title}
									</h3>
									<p className="text-sm text-indigo-100">
										{resource.description}
									</p>
								</div>
								<Link
									href={resource.actionHref}
									className="mt-6 inline-flex items-center text-sm font-semibold text-indigo-100 underline decoration-indigo-200/40 underline-offset-4 transition group-hover:text-white"
								>
									{resource.actionLabel} →
								</Link>
							</div>
						))}
					</div>
				</section>

				<section
					id="stories"
					className="mt-20 grid gap-8 rounded-3xl border border-white/10 bg-slate-900/70 p-10 shadow-2xl shadow-indigo-500/10 backdrop-blur-lg lg:grid-cols-[1fr_1.1fr]"
				>
					<div className="space-y-6">
						<h2 className="text-3xl font-semibold text-white">
							世界中のクリエイターが信頼するプラットフォーム。
						</h2>
						<p className="text-base text-slate-300">
							React Aria によるアクセシビリティを軸に設計された UI
							パターンは、どのデバイスでも一貫した操作感を保証します。Tailwind
							はチームのスピードを損なうことなく、ブランドの個性を守ります。
						</p>
						<Button
							onPress={() =>
								window.open(
									helpServiceUrl ? `https://${helpServiceUrl}` : "#",
									"_blank",
								)
							}
							className="inline-flex items-center gap-2 rounded-full bg-indigo-500 px-5 py-2 text-sm font-semibold text-white transition hover:bg-indigo-400 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-200"
						>
							導入ストーリーを読む
						</Button>
					</div>

					<div className="grid gap-6">
						{testimonials.map((testimonial) => (
							<figure
								key={testimonial.name}
								className="rounded-3xl border border-white/10 bg-white/5 p-6 text-slate-100 shadow-lg shadow-black/20"
							>
								<blockquote className="text-sm leading-relaxed">
									{testimonial.message}
								</blockquote>
								<figcaption className="mt-4 text-xs uppercase tracking-[0.3em] text-slate-300">
									{testimonial.name} — {testimonial.role}
								</figcaption>
							</figure>
						))}
					</div>
				</section>

				<section className="mt-20 rounded-3xl border border-white/10 bg-white/10 p-10 text-slate-900 shadow-2xl shadow-indigo-500/20">
					<div className="grid gap-8 lg:grid-cols-[1.1fr_0.9fr] lg:items-center">
						<div className="space-y-4">
							<h2 className="text-3xl font-semibold">
								数分でローンチを完了。あなたのコミュニティに最適化された設定を。
							</h2>
							<p className="text-base text-slate-700">
								アクセシビリティのベストプラクティスと Tailwind
								コンポーネントを組み合わせたスターターテンプレートを、サインアップ直後からご利用いただけます。
							</p>
						</div>
						<div className="flex flex-col gap-4 rounded-3xl border border-slate-900/10 bg-white/70 p-6">
							<p className="text-xs font-semibold uppercase tracking-[0.3em] text-slate-500">
								レコメンドされた次のステップ
							</p>
							<Button
								onPress={() =>
									window.open(
										rootServiceUrl ? `https://${rootServiceUrl}/sign_up` : "#",
										"_blank",
									)
								}
								className="inline-flex items-center justify-center rounded-full bg-slate-900 px-5 py-3 text-sm font-semibold text-white transition hover:bg-slate-800 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-slate-800"
							>
								ワークスペースを作成
							</Button>
							<Link
								href={helpServiceUrl ? `https://${helpServiceUrl}` : "#"}
								className="inline-flex items-center justify-center rounded-full border border-slate-900/10 px-5 py-3 text-sm font-semibold text-slate-900 transition hover:border-slate-900/20 hover:bg-white"
							>
								導入ガイドを読む
							</Link>
						</div>
					</div>
				</section>
			</main>

			<Footer
				codeName={codeName}
				rootServiceUrl={rootServiceUrl}
				docsServiceUrl={docsServiceUrl}
				helpServiceUrl={helpServiceUrl}
				newsServiceUrl={newsServiceUrl}
			/>
		</div>
	);
};

export default RootAppLanding;
