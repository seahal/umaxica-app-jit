import type React from "react";
import {
	Button,
	Group,
	Input,
	Label,
	Link,
	SearchField,
	Separator,
	Tab,
	TabList,
	TabPanel,
	Tabs,
	ToggleButton,
} from "react-aria-components";

type Feature = {
	id: string;
	name: string;
	description: string;
	highlights: string[];
};

const heroStats = [
	{ label: "Creator collectives launched", value: "12k+" },
	{ label: "Weekly active collaborations", value: "58%" },
	{ label: "Average response uplift", value: "3.4×" },
];

const featurePanels: Feature[] = [
	{
		id: "community",
		name: "Community spaces",
		description:
			"Orchestrate onboarding rituals, coordinate launches, and retain advocates with automated welcome flows and pulse checks.",
		highlights: [
			"Adaptive welcome sequences tailored by timezone and language.",
			"Playbooks for creators, moderators, and brand partners in one hub.",
			"Status dashboards that clarify who's thriving and who needs a nudge.",
		],
	},
	{
		id: "studio",
		name: "Content studio",
		description:
			"Prototype interactive posts with accessible defaults, then syndicate across feeds with real-time audience previews.",
		highlights: [
			"Drag-in components backed by React Aria patterns for instant accessibility.",
			"Reusable layout tokens keep every story on-brand across locales.",
			"Audience heatmaps reveal the moments your community leans in.",
		],
	},
	{
		id: "insights",
		name: "Insight loops",
		description:
			"Close the loop by weaving qualitative stories and quantitative signals into one actionable rhythm.",
		highlights: [
			"Sentiment snapshots combine polls, mentions, and support notes.",
			"Impact tracker ties every campaign to activation and retention.",
			"Automated recaps ship to stakeholders without extra busywork.",
		],
	},
];

const blueprintColumns = [
	{
		title: "Circle scaffolding",
		items: [
			"Starter templates for interest-based channels and event arcs.",
			"Guided moderation rituals to keep voices equitable.",
			"Role-based permissions mapped to trust tiers.",
		],
	},
	{
		title: "Moments that resonate",
		items: [
			"Story prompts and Q&A kits tailored to emerging trends.",
			"Signals to surface underrepresented perspectives faster.",
			"AI-assisted caption polish with inclusive language hints.",
		],
	},
	{
		title: "Insight cadence",
		items: [
			"Weekly digest that celebrates momentum and flags friction.",
			"Archive of qualitative gems to reuse in launch decks.",
			"Direct handoffs into support, product, and marketing squads.",
		],
	},
];

const HelpComLanding: React.FC = () => {
	return (
		<div className="min-h-screen bg-slate-950 text-slate-50">
			<div className="mx-auto flex w-full max-w-6xl flex-col gap-16 px-4 py-16 sm:px-6 lg:px-8 lg:py-24">
				<section className="grid gap-12 lg:grid-cols-12 lg:items-start">
					<div className="flex flex-col gap-8 lg:col-span-7">
						<div className="max-w-3xl space-y-4">
							<span className="inline-flex items-center rounded-full border border-indigo-400/40 bg-indigo-500/10 px-4 py-1 text-xs font-semibold uppercase tracking-[0.3em] text-indigo-200">
								Next wave social collaboration
							</span>
							<h1 className="text-4xl font-semibold leading-tight tracking-tight text-white sm:text-5xl lg:text-6xl">
								Design collaborative stories your community can feel.
							</h1>
							<p className="text-lg text-slate-200 sm:text-xl">
								Help Center for creators, strategists, and community architects
								building the most welcoming spaces on{" "}
								<span className="font-semibold text-indigo-200">Umaxica</span>.
								Explore inclusive UI patterns powered by React Aria and see how
								dynamic teams stay in flow.
							</p>
						</div>

						<div className="flex flex-wrap gap-4">
							<Button
								className="rounded-full bg-indigo-500 px-6 py-3 text-sm font-semibold text-white shadow-lg shadow-indigo-500/40 transition hover:bg-indigo-400 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-300"
								onPress={() =>
									window.scrollTo({
										top: window.innerHeight,
										behavior: "smooth",
									})
								}
							>
								Start a creator space tour
							</Button>
							<Button className="rounded-full border border-white/20 px-6 py-3 text-sm font-semibold text-slate-100 transition hover:border-white/40 hover:bg-white/10 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-300">
								View accessibility checklist
							</Button>
						</div>

						<SearchField
							aria-label="Search the help center"
							className="w-full max-w-2xl"
							onSubmit={() => window.alert("Search coming soon.")}
						>
							<Label className="sr-only">Search the help center</Label>
							<Group className="flex items-stretch overflow-hidden rounded-full border border-white/15 bg-white/5 backdrop-blur-xl">
								<Input
									className="flex-1 bg-transparent px-5 py-3 text-base text-white placeholder:text-slate-400 focus:outline-none"
									placeholder="Search playbooks, interaction patterns, or launch guides..."
								/>
								<Button className="m-1 rounded-full bg-indigo-500 px-5 text-sm font-semibold text-white transition hover:bg-indigo-400 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-300">
									Search
								</Button>
							</Group>
						</SearchField>

						<dl className="grid grid-cols-1 gap-6 sm:grid-cols-3">
							{heroStats.map((stat) => (
								<div
									key={stat.label}
									className="rounded-2xl border border-white/10 bg-white/5 p-5 backdrop-blur-xl"
								>
									<dt className="text-xs font-medium uppercase tracking-widest text-slate-300">
										{stat.label}
									</dt>
									<dd className="mt-3 text-3xl font-semibold text-white">
										{stat.value}
									</dd>
								</div>
							))}
						</dl>
					</div>

					<div className="flex flex-col gap-6 rounded-3xl border border-white/10 bg-gradient-to-br from-white/10 via-white/5 to-slate-900/60 p-6 shadow-2xl shadow-indigo-500/10 backdrop-blur-2xl lg:col-span-5">
						<Tabs
							defaultSelectedKey={featurePanels[0].id}
							className="flex flex-col gap-6"
						>
							<TabList
								aria-label="Platform modes"
								className="flex flex-wrap gap-2 rounded-2xl bg-white/5 p-2"
							>
								{featurePanels.map((feature) => (
									<Tab
										key={feature.id}
										id={feature.id}
										className={({ isSelected }) =>
											[
												"rounded-full px-4 py-2 text-sm font-semibold transition focus:outline-none",
												isSelected
													? "bg-indigo-500 text-white shadow-lg shadow-indigo-500/40"
													: "text-slate-300 hover:bg-white/10 hover:text-white",
											].join(" ")
										}
									>
										{feature.name}
									</Tab>
								))}
							</TabList>

							{featurePanels.map((feature) => (
								<TabPanel
									key={feature.id}
									id={feature.id}
									className="rounded-2xl border border-white/10 bg-slate-900/60 p-6 text-slate-100"
								>
									<div className="space-y-4">
										<h3 className="text-xl font-semibold text-white">
											{feature.name}
										</h3>
										<p className="text-sm leading-relaxed text-slate-200">
											{feature.description}
										</p>
										<ul className="space-y-3 text-sm text-slate-200">
											{feature.highlights.map((highlight) => (
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
											Read the implementation guide →
										</Link>
									</div>
								</TabPanel>
							))}
						</Tabs>

						<Separator className="h-px w-full bg-white/10" />

						<div className="space-y-4">
							<ToggleButton
								defaultSelected
								className={({ isSelected, isFocusVisible }) =>
									[
										"w-full rounded-2xl border border-white/10 bg-white/5 p-5 text-left transition",
										isSelected
											? "border-indigo-400/60 shadow-md shadow-indigo-500/20"
											: "",
										isFocusVisible
											? "outline outline-2 outline-offset-2 outline-indigo-300"
											: "",
									]
										.filter(Boolean)
										.join(" ")
								}
							>
								{({ isSelected }) => (
									<div className="flex flex-col gap-2">
										<div className="flex items-center justify-between gap-3">
											<span className="text-sm font-semibold text-white">
												Adaptive onboarding rituals
											</span>
											<span
												className={[
													"rounded-full px-3 py-1 text-xs font-semibold uppercase tracking-wide transition",
													isSelected
														? "bg-indigo-500/80 text-white"
														: "bg-white/10 text-slate-200",
												].join(" ")}
											>
												{isSelected ? "Active" : "Paused"}
											</span>
										</div>
										<p className="text-sm text-slate-200">
											Time-zone aware welcome sequences keep every new voice seen
											during their first 48 hours.
										</p>
									</div>
								)}
							</ToggleButton>

							<ToggleButton
								className={({ isSelected, isFocusVisible }) =>
									[
										"w-full rounded-2xl border border-white/10 bg-white/5 p-5 text-left transition",
										isSelected
											? "border-emerald-400/60 shadow-md shadow-emerald-500/20"
											: "",
										isFocusVisible
											? "outline outline-2 outline-offset-2 outline-emerald-300"
											: "",
									]
										.filter(Boolean)
										.join(" ")
								}
							>
								{({ isSelected }) => (
									<div className="flex flex-col gap-2">
										<div className="flex items-center justify-between gap-3">
											<span className="text-sm font-semibold text-white">
												Notify mentors when a thread needs care
											</span>
											<span
												className={[
													"rounded-full px-3 py-1 text-xs font-semibold uppercase tracking-wide transition",
													isSelected
														? "bg-emerald-500/80 text-white"
														: "bg-white/10 text-slate-200",
												].join(" ")}
											>
												{isSelected ? "Active" : "Paused"}
											</span>
										</div>
										<p className="text-sm text-slate-200">
											Route calm, constructive voices to conversations the moment
											sentiment shifts.
										</p>
									</div>
								)}
							</ToggleButton>
						</div>
					</div>
				</section>

				<section className="rounded-3xl border border-white/5 bg-gradient-to-r from-indigo-600/30 via-indigo-500/20 to-emerald-500/25 p-10 text-slate-50 shadow-2xl shadow-emerald-500/20">
					<div className="max-w-3xl space-y-4">
						<h2 className="text-3xl font-semibold tracking-tight text-white sm:text-4xl">
							Blueprint a launch your audience will celebrate.
						</h2>
						<p className="text-base text-indigo-100">
							This help center edition curates facilitation patterns, moderation
							safeguards, and story prompts so your community feels co-created
							from day one.
						</p>
					</div>

					<div className="mt-10 grid gap-8 md:grid-cols-3">
						{blueprintColumns.map((column) => (
							<div
								key={column.title}
								className="space-y-4 rounded-2xl border border-white/10 bg-slate-950/40 p-6"
							>
								<h3 className="text-lg font-semibold text-white">
									{column.title}
								</h3>
								<ul className="space-y-3 text-sm leading-relaxed text-indigo-100">
									{column.items.map((item) => (
										<li key={item} className="flex gap-3">
											<span
												className="mt-1 inline-flex h-2 w-2 flex-none rounded-full bg-emerald-300"
												aria-hidden
											/>
											<span>{item}</span>
										</li>
									))}
								</ul>
							</div>
						))}
					</div>

					<div className="mt-10 flex flex-wrap gap-4 text-sm text-indigo-100">
						<Button className="rounded-full border border-white/20 px-5 py-2 font-semibold text-white transition hover:border-white/40 hover:bg-white/10 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-emerald-300">
							Download facilitation kit
						</Button>
						<Button className="rounded-full border border-transparent bg-white/15 px-5 py-2 font-semibold text-white shadow-lg shadow-emerald-400/30 transition hover:bg-white/25 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-white">
							Request a co-design session
						</Button>
					</div>
				</section>
			</div>
		</div>
	);
};

export default HelpComLanding;
