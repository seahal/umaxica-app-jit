import type { FC } from "react";
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

type HeaderProps = {
	codeName: string;
	helpServiceUrl: string;
	docsServiceUrl: string;
	newsServiceUrl: string;
};

type FooterProps = {
	codeName: string;
};

type HelpAppLandingProps = {
	codeName?: string;
	helpServiceUrl?: string;
	docsServiceUrl?: string;
	newsServiceUrl?: string;
};

type KnowledgePane = {
	id: string;
	name: string;
	description: string;
	highlights: string[];
};

type QuickSolution = {
	title: string;
	description: string;
	action: string;
};

type ResourceCard = {
	title: string;
	description: string;
	category: string;
};

type UpdateCard = {
	title: string;
	description: string;
	date: string;
};

const navigationItems = [
	{ href: "/message", icon: "💬", tooltip: "メッセージ" },
	{ href: "/notification", icon: "🔔", tooltip: "通知" },
	{ href: "/configuration", icon: "⚙️", tooltip: "設定" },
];

const quickSolutions: QuickSolution[] = [
	{
		title: "アカウントとアクセス",
		description: "ログイン、多要素認証、パスキーなどの設定方法。",
		action: "パスキーガイドを見る",
	},
	{
		title: "コミュニティ運営",
		description: "モデレーションや投稿テンプレートのベストプラクティス。",
		action: "モデレーション手順を確認",
	},
	{
		title: "クリエイター向け収益化",
		description: "サブスクリプションとスポンサーシップのセットアップ。",
		action: "収益化のチェックリスト",
	},
];

const knowledgePanes: KnowledgePane[] = [
	{
		id: "starter",
		name: "スタートガイド",
		description:
			"新しいワークスペースの立ち上げからメンバー招待、デザインの初期設定までを段階的にサポートします。",
		highlights: [
			"ワークスペース作成時の推奨設定と権限テンプレート。",
			"アクセシブルなページ構造のパターン集。",
			"初回メンバー向けオンボーディングメッセージの例文。",
		],
	},
	{
		id: "collab",
		name: "コラボレーション",
		description:
			"チームでの情報共有やフィードバック収集を、ワークフローに沿ったかたちで推進する方法を紹介します。",
		highlights: [
			"プロジェクト別の更新テンプレートと進捗チェックリスト。",
			"ライブ配信やAMAイベントの実施フロー。",
			"アナウンスとフォローアップのベストタイミング。",
		],
	},
	{
		id: "insights",
		name: "インサイトと分析",
		description:
			"コミュニティの反応を計測し、次の施策につなげるインサイトの集め方をまとめました。",
		highlights: [
			"ファンの声を定量・定性的に統合するダッシュボード設計。",
			"ニュースレターや特集記事への転用方法。",
			"ステークホルダー共有に使える週次レポートの雛形。",
		],
	},
];

const resourceCards: ResourceCard[] = [
	{
		title: "配信イベントの準備キット",
		description:
			"舞台裏のチェックリスト、スピーカー向けガイド、当日の進行シナリオを揃えました。",
		category: "イベント運営",
	},
	{
		title: "視覚デザインアクセシビリティ",
		description:
			"カラーモードやコントラスト、レスポンシブレイアウトの推奨パターンを確認しましょう。",
		category: "デザインシステム",
	},
	{
		title: "安全なコミュニティづくり",
		description:
			"モデレーションポリシー、報告フロー、自動検知の設定をまとめたハンドブック。",
		category: "セーフティ",
	},
];

const latestUpdates: UpdateCard[] = [
	{
		title: "コミュニティの健康スコアが新登場",
		description:
			"メンバーのアクティビティとフィードバックを組み合わせ、早期に変化を察知できます。",
		date: "2024-04-12",
	},
	{
		title: "ワークスペースカタログが刷新されました",
		description:
			"成功事例のテンプレートを検索しやすく整理。活用のためのチェックポイント付き。",
		date: "2024-03-29",
	},
];

const Header: FC<HeaderProps> = ({
	codeName,
	helpServiceUrl,
	docsServiceUrl,
	newsServiceUrl,
}) => {
	const currentPath =
		typeof window !== "undefined" ? window.location.pathname : "/";

	const renderNavLinkClass = (href: string) => {
		const isActive = currentPath === href;
		const baseClasses =
			"group relative rounded-lg px-3 py-1.5 text-xs font-medium transition-all duration-200 outline-none focus-visible:ring-2 focus-visible:ring-blue-500 sm:text-sm";

		return isActive
			? `${baseClasses} scale-110 bg-blue-100 text-blue-600 dark:bg-blue-900/30 dark:text-blue-400`
			: `${baseClasses} text-gray-700 hover:scale-105 hover:bg-gray-100 dark:text-gray-300 dark:hover:bg-gray-800`;
	};

	return (
		<header className="sticky top-0 z-50 border-b border-gray-200 bg-white/80 backdrop-blur-md dark:border-gray-800 dark:bg-gray-950/80">
			<div className="mx-auto max-w-7xl px-2 sm:px-4">
				<div className="flex min-h-16 flex-wrap items-center gap-2 py-2">
					<Link
						href="/"
						className="flex shrink-0 items-center gap-2 rounded-lg px-2 py-1 outline-none transition-transform hover:scale-105 focus-visible:ring-2 focus-visible:ring-blue-500"
					>
						<div className="flex h-8 w-8 items-center justify-center rounded-lg bg-gradient-to-br from-blue-500 to-purple-600 shadow-md">
							<svg
								className="h-5 w-5 text-white"
								fill="none"
								stroke="currentColor"
								viewBox="0 0 24 24"
								aria-hidden="true"
							>
								<title>{codeName}</title>
								<path
									strokeLinecap="round"
									strokeLinejoin="round"
									strokeWidth={2}
									d="M17 8h2a2 2 0 012 2v6a2 2 0 01-2 2h-2v4l-4-4H9a1.994 1.994 0 01-1.414-.586m0 0L11 14h4a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2v4l.586-.586z"
								/>
							</svg>
						</div>
						<span className="text-sm font-bold text-gray-900 dark:text-white sm:text-base">
							{codeName}
						</span>
					</Link>

					<nav className="flex flex-wrap items-center gap-1">
						{navigationItems.map((item) => (
							<TooltipTrigger delay={0} key={item.href}>
								<Link
									href={item.href}
									aria-current={currentPath === item.href ? "page" : undefined}
									className={renderNavLinkClass(item.href)}
								>
									<span aria-hidden>{item.icon}</span>
								</Link>
								<Tooltip className="animate-in fade-in zoom-in-95 rounded-lg bg-gray-900 px-3 py-1.5 text-xs text-white shadow-lg dark:bg-gray-100 dark:text-gray-900">
									{item.tooltip}
								</Tooltip>
							</TooltipTrigger>
						))}

						{newsServiceUrl ? (
							<TooltipTrigger delay={0}>
								<Link
									href={`https://${newsServiceUrl}`}
									target="_blank"
									rel="noopener noreferrer"
									className="rounded-lg px-3 py-1.5 text-xs font-medium text-gray-700 transition-all duration-200 hover:scale-105 hover:bg-gray-100 outline-none focus-visible:ring-2 focus-visible:ring-blue-500 dark:text-gray-300 dark:hover:bg-gray-800 sm:text-sm"
								>
									<span aria-hidden>📰</span>
								</Link>
								<Tooltip className="animate-in fade-in zoom-in-95 rounded-lg bg-gray-900 px-3 py-1.5 text-xs text-white shadow-lg dark:bg-gray-100 dark:text-gray-900">
									ニュース
								</Tooltip>
							</TooltipTrigger>
						) : null}

						{docsServiceUrl ? (
							<TooltipTrigger delay={0}>
								<Link
									href={`https://${docsServiceUrl}`}
									target="_blank"
									rel="noopener noreferrer"
									className="rounded-lg px-3 py-1.5 text-xs font-medium text-gray-700 transition-all duration-200 hover:scale-105 hover:bg-gray-100 outline-none focus-visible:ring-2 focus-visible:ring-blue-500 dark:text-gray-300 dark:hover:bg-gray-800 sm:text-sm"
								>
									<span aria-hidden>📚</span>
								</Link>
								<Tooltip className="animate-in fade-in zoom-in-95 rounded-lg bg-gray-900 px-3 py-1.5 text-xs text-white shadow-lg dark:bg-gray-100 dark:text-gray-900">
									ドキュメント
								</Tooltip>
							</TooltipTrigger>
						) : null}

						{helpServiceUrl ? (
							<TooltipTrigger delay={0}>
								<Link
									href={`https://${helpServiceUrl}`}
									target="_blank"
									rel="noopener noreferrer"
									className="rounded-lg px-3 py-1.5 text-xs font-medium text-gray-700 transition-all duration-200 hover:scale-105 hover:bg-gray-100 outline-none focus-visible:ring-2 focus-visible:ring-blue-500 dark:text-gray-300 dark:hover:bg-gray-800 sm:text-sm"
								>
									<span aria-hidden>❓</span>
								</Link>
								<Tooltip className="animate-in fade-in zoom-in-95 rounded-lg bg-gray-900 px-3 py-1.5 text-xs text-white shadow-lg dark:bg-gray-100 dark:text-gray-900">
									ヘルプ
								</Tooltip>
							</TooltipTrigger>
						) : null}
					</nav>

					<div className="ml-auto flex flex-wrap items-center gap-3">
						<Link
							href="/explore"
							className={({ isPressed }) =>
								[
									"inline-flex items-center gap-1.5 rounded-full px-3 py-1.5 text-xs font-bold transition-all outline-none focus-visible:ring-2 focus-visible:ring-blue-500 sm:px-4 sm:text-sm",
									isPressed
										? "scale-95 bg-gray-900 text-white dark:bg-gray-100 dark:text-gray-900"
										: "bg-gray-900 text-white hover:bg-gray-800 dark:bg-gray-100 dark:text-gray-900 dark:hover:bg-gray-200",
								].join(" ")
							}
						>
							<svg
								className="h-3.5 w-3.5 sm:h-4 sm:w-4"
								fill="none"
								stroke="currentColor"
								viewBox="0 0 24 24"
								aria-hidden="true"
							>
								<title>Explore</title>
								<path
									strokeLinecap="round"
									strokeLinejoin="round"
									strokeWidth={2}
									d="M10 20l4-16m4 4 4 4-4 4m-12-4l-4 4 4 4"
								/>
							</svg>
							Explore
						</Link>

						<Link
							href="/authentication"
							className={({ isPressed }) =>
								[
									"inline-flex items-center gap-1.5 rounded-full px-3 py-1.5 text-xs font-bold transition-all outline-none focus-visible:ring-2 focus-visible:ring-blue-500 sm:px-4 sm:text-sm",
									isPressed
										? "scale-95 bg-gray-900 text-white dark:bg-gray-100 dark:text-gray-900"
										: "bg-gray-900 text-white hover:bg-gray-800 dark:bg-gray-100 dark:text-gray-900 dark:hover:bg-gray-200",
								].join(" ")
							}
						>
							<svg
								className="h-3.5 w-3.5 sm:h-4 sm:w-4"
								fill="none"
								stroke="currentColor"
								viewBox="0 0 24 24"
								aria-hidden="true"
							>
								<title>Login</title>
								<path
									strokeLinecap="round"
									strokeLinejoin="round"
									strokeWidth={2}
									d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
								/>
							</svg>
							Login
						</Link>
					</div>
				</div>
			</div>
		</header>
	);
};

const Footer: FC<FooterProps> = ({ codeName }) => {
	const currentYear = new Date().getFullYear();

	return (
		<footer className="relative mt-auto border-t border-gray-200 bg-gradient-to-b from-white to-gray-50 dark:border-gray-800 dark:from-gray-950 dark:to-gray-900">
			<div className="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
				<div className="grid grid-cols-1 gap-8 md:grid-cols-3 lg:gap-12">
					<div className="space-y-4 animate-in fade-in slide-in-from-bottom-4 duration-700">
						<h3 className="text-lg font-semibold tracking-tight text-gray-900 dark:text-white">
							{codeName}
						</h3>
						<p className="text-sm leading-relaxed text-gray-600 dark:text-gray-400">
							最先端技術でモダンな Web 体験を構築
						</p>
					</div>

					<div className="space-y-4 animate-in fade-in slide-in-from-bottom-4 duration-700 delay-150">
						<h4 className="text-sm font-semibold uppercase tracking-wider text-gray-900 dark:text-white">
							クイックリンク
						</h4>
						<nav className="flex flex-col space-y-3">
							{[
								{ href: "/", label: "ホーム", tooltip: "トップページに戻る" },
								{
									href: "/about",
									label: "About",
									tooltip: "私たちについて",
								},
								{
									href: "/contact",
									label: "お問い合わせ",
									tooltip: "ご質問・ご相談はこちら",
								},
							].map((item) => (
								<TooltipTrigger delay={200} key={item.href}>
									<Link
										href={item.href}
										className="group inline-flex w-fit items-center text-sm text-gray-600 transition-all duration-300 hover:translate-x-1 hover:text-gray-900 dark:text-gray-400 dark:hover:text-white"
									>
										<span className="relative">
											{item.label}
											<span className="absolute bottom-0 left-0 h-px w-0 bg-current transition-all duration-300 group-hover:w-full" />
										</span>
									</Link>
									<Tooltip className="animate-in fade-in zoom-in-95 rounded-lg bg-gray-900 px-3 py-1.5 text-xs text-white shadow-lg dark:bg-gray-100 dark:text-gray-900">
										{item.tooltip}
									</Tooltip>
								</TooltipTrigger>
							))}
						</nav>
					</div>

					<div className="space-y-4 animate-in fade-in slide-in-from-bottom-4 duration-700 delay-300">
						<h4 className="text-sm font-semibold uppercase tracking-wider text-gray-900 dark:text-white">
							つながる
						</h4>
						<div className="flex flex-wrap gap-4">
							<TooltipTrigger delay={0}>
								<Link
									href="https://github.com/seahal/umaxica-app-edge"
									target="_blank"
									rel="noopener noreferrer"
									className="group flex h-10 w-10 items-center justify-center rounded-full bg-gray-100 text-gray-600 transition-all duration-300 hover:scale-110 hover:rotate-6 hover:bg-gray-900 hover:text-white dark:bg-gray-800 dark:text-gray-400 dark:hover:bg-white dark:hover:text-gray-900"
									aria-label="GitHub"
								>
									<svg
										className="h-5 w-5"
										fill="currentColor"
										viewBox="0 0 24 24"
										aria-hidden="true"
									>
										<title>GitHub</title>
										<path
											fillRule="evenodd"
											d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z"
											clipRule="evenodd"
										/>
									</svg>
								</Link>
								<Tooltip className="animate-in fade-in zoom-in-95 rounded-lg bg-gray-900 px-3 py-1.5 text-xs text-white shadow-lg dark:bg-gray-100 dark:text-gray-900">
									GitHubでソースコードを見る
								</Tooltip>
							</TooltipTrigger>

							<TooltipTrigger delay={0}>
								<Link
									href="https://twitter.com"
									target="_blank"
									rel="noopener noreferrer"
									className="group flex h-10 w-10 items-center justify-center rounded-full bg-gray-100 text-gray-600 transition-all duration-300 hover:scale-110 hover:rotate-6 hover:bg-blue-500 hover:text-white dark:bg-gray-800 dark:text-gray-400 dark:hover:bg-blue-500"
									aria-label="Twitter"
								>
									<svg
										className="h-5 w-5"
										fill="currentColor"
										viewBox="0 0 24 24"
										aria-hidden="true"
									>
										<title>Twitter</title>
										<path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
									</svg>
								</Link>
								<Tooltip className="animate-in fade-in zoom-in-95 rounded-lg bg-gray-900 px-3 py-1.5 text-xs text-white shadow-lg dark:bg-gray-100 dark:text-gray-900">
									Twitterでフォロー
								</Tooltip>
							</TooltipTrigger>
						</div>
					</div>
				</div>

				<div className="mt-12 animate-in fade-in duration-700 delay-500 border-t border-gray-200 pt-8 dark:border-gray-800">
					<div className="flex flex-col items-center justify-between gap-4 sm:flex-row">
						<p className="text-center text-sm text-gray-600 dark:text-gray-400">
							© {currentYear} {codeName}. All rights reserved.
						</p>
						<div className="flex flex-wrap justify-center gap-6">
							{[
								{
									href: "/privacy",
									label: "プライバシーポリシー",
									tooltip: "個人情報の取り扱いについて",
								},
								{
									href: "/terms",
									label: "利用規約",
									tooltip: "サービス利用の規約",
								},
							].map((item) => (
								<TooltipTrigger delay={200} key={item.href}>
									<Link
										href={item.href}
										className="text-sm text-gray-600 transition-all duration-200 hover:scale-105 hover:text-gray-900 dark:text-gray-400 dark:hover:text-white"
									>
										{item.label}
									</Link>
									<Tooltip className="animate-in fade-in zoom-in-95 rounded-lg bg-gray-900 px-3 py-1.5 text-xs text-white shadow-lg dark:bg-gray-100 dark:text-gray-900">
										{item.tooltip}
									</Tooltip>
								</TooltipTrigger>
							))}
						</div>
					</div>
				</div>
			</div>

			<div className="pointer-events-none absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-gray-300 to-transparent animate-pulse dark:via-gray-700" />
		</footer>
	);
};

const HelpAppLanding: FC<HelpAppLandingProps> = ({
	codeName = "Umaxica",
	helpServiceUrl = "",
	docsServiceUrl = "",
	newsServiceUrl = "",
}) => {
	return (
		<div className="flex min-h-screen flex-col bg-slate-950 text-slate-50">
			<Header
				codeName={codeName}
				helpServiceUrl={helpServiceUrl}
				docsServiceUrl={docsServiceUrl}
				newsServiceUrl={newsServiceUrl}
			/>

			<main className="mx-auto w-full max-w-7xl flex-1 px-4 py-16 sm:px-6 lg:px-8 lg:py-20">
				<section className="grid gap-12 lg:grid-cols-12 lg:items-start">
					<div className="flex flex-col gap-10 lg:col-span-7">
						<div className="max-w-3xl space-y-5">
							<span className="inline-flex items-center rounded-full border border-blue-400/40 bg-blue-500/10 px-4 py-1 text-xs font-semibold uppercase tracking-[0.3em] text-blue-200">
								Help Center for Creators
							</span>
							<h1 className="text-4xl font-semibold leading-tight tracking-tight text-white sm:text-5xl">
								コミュニティ運営の疑問を、すぐに解決。
							</h1>
							<p className="text-lg text-slate-200 sm:text-xl">
								{codeName} のヘルプセンターへようこそ。アクセシブルな UI
								パターンと実践的なワークフローで、コミュニティ運営を次の
								レベルへ導きます。
							</p>
						</div>

						<SearchField
							aria-label="ヘルプセンター内を検索"
							className="w-full max-w-2xl"
							onSubmit={() => window.alert("検索機能は近日公開予定です。")}
						>
							<Label className="sr-only">ヘルプセンター内を検索</Label>
							<Group className="flex items-stretch overflow-hidden rounded-full border border-white/10 bg-white/5 backdrop-blur-xl">
								<Input
									className="flex-1 bg-transparent px-5 py-3 text-base text-white placeholder:text-slate-400 focus:outline-none"
									placeholder="キーワード、ガイド、またはテンプレートを検索..."
								/>
								<Button className="m-1 rounded-full bg-indigo-500 px-5 text-sm font-semibold text-white transition hover:bg-indigo-400 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-300">
									検索
								</Button>
							</Group>
						</SearchField>

						<div className="grid gap-4 sm:grid-cols-2">
							{quickSolutions.map((solution) => (
								<div
									key={solution.title}
									className="rounded-3xl border border-white/10 bg-white/5 p-6 backdrop-blur-xl transition hover:border-white/20 hover:bg-white/10"
								>
									<h2 className="text-lg font-semibold text-white">
										{solution.title}
									</h2>
									<p className="mt-2 text-sm text-slate-200">
										{solution.description}
									</p>
									<Link
										href="#"
										className="mt-4 inline-flex items-center text-sm font-semibold text-indigo-200 transition hover:text-indigo-100"
									>
										{solution.action} →
									</Link>
								</div>
							))}
						</div>
					</div>

					<div className="flex flex-col gap-6 rounded-3xl border border-white/10 bg-slate-900/60 p-6 shadow-2xl shadow-blue-500/10 backdrop-blur-2xl lg:col-span-5">
						<Tabs defaultSelectedKey={knowledgePanes[0]?.id}>
							<TabList
								aria-label="ナレッジベースカテゴリ"
								className="flex flex-wrap gap-2 rounded-2xl bg-white/5 p-2"
							>
								{knowledgePanes.map((pane) => (
									<Tab
										key={pane.id}
										id={pane.id}
										className={({ isSelected }) =>
											[
												"rounded-full px-4 py-2 text-sm font-semibold transition focus:outline-none",
												isSelected
													? "bg-indigo-500 text-white shadow-lg shadow-indigo-500/40"
													: "text-slate-300 hover:bg-white/10 hover:text-white",
											].join(" ")
										}
									>
										{pane.name}
									</Tab>
								))}
							</TabList>

							{knowledgePanes.map((pane) => (
								<TabPanel
									key={pane.id}
									id={pane.id}
									className="rounded-2xl border border-white/10 bg-slate-950/30 p-6 text-slate-100"
								>
									<div className="space-y-4">
										<h3 className="text-xl font-semibold text-white">
											{pane.name}
										</h3>
										<p className="text-sm leading-relaxed text-slate-200">
											{pane.description}
										</p>
										<ul className="space-y-3 text-sm text-slate-200">
											{pane.highlights.map((highlight) => (
												<li key={highlight} className="flex gap-3">
													<span
														className="mt-1 inline-flex h-2 w-2 flex-none rounded-full bg-indigo-400"
														aria-hidden
													/>
													<span>{highlight}</span>
												</li>
											))}
										</ul>
										<Link
											href="#"
											className="inline-flex items-center text-sm font-semibold text-indigo-200 transition hover:text-indigo-100"
										>
											詳細を見る →
										</Link>
									</div>
								</TabPanel>
							))}
						</Tabs>

						<div className="rounded-2xl border border-white/10 bg-white/5 p-6">
							<h3 className="text-sm font-semibold uppercase tracking-wide text-slate-200">
								最新のお知らせ
							</h3>
							<ul className="mt-4 space-y-4">
								{latestUpdates.map((update) => (
									<li key={update.title} className="space-y-1.5">
										<p className="text-sm font-medium text-white">
											{update.title}
										</p>
										<p className="text-xs text-slate-300">
											{update.description}
										</p>
										<span className="text-xs text-slate-400">
											{update.date}
										</span>
									</li>
								))}
							</ul>
						</div>
					</div>
				</section>

				<section className="mt-16 space-y-8 rounded-3xl border border-white/5 bg-gradient-to-r from-indigo-600/30 via-indigo-500/20 to-purple-500/25 p-10 text-slate-50 shadow-2xl shadow-indigo-500/20">
					<header className="max-w-3xl space-y-4">
						<h2 className="text-3xl font-semibold tracking-tight text-white sm:text-4xl">
							おすすめのリソース
						</h2>
						<p className="text-base text-indigo-100">
							コミュニティに活力をもたらす最新のテンプレートとガイドをピックアップしました。
						</p>
					</header>

					<div className="grid gap-6 md:grid-cols-3">
						{resourceCards.map((resource) => (
							<div
								key={resource.title}
								className="space-y-3 rounded-2xl border border-white/10 bg-slate-950/40 p-6"
							>
								<p className="text-xs font-semibold uppercase tracking-wide text-indigo-200">
									{resource.category}
								</p>
								<h3 className="text-lg font-semibold text-white">
									{resource.title}
								</h3>
								<p className="text-sm text-indigo-100">
									{resource.description}
								</p>
								<Link
									href="#"
									className="inline-flex items-center text-sm font-semibold text-indigo-200 transition hover:text-indigo-100"
								>
									ガイドを見る →
								</Link>
							</div>
						))}
					</div>
				</section>
			</main>

			<Footer codeName={codeName} />
		</div>
	);
};

export default HelpAppLanding;
