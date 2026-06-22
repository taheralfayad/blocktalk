<script lang="ts">
	import Entry from "$lib/components/entry.svelte";
	import rightArrow from "$lib/assets/right.svg";
	import {
		getDistance,
		getLocationSearchValue,
	} from "$lib/states/searchBarState.svelte.js";
	import { fly } from "svelte/transition";
	import { onMount } from "svelte";
	import { goto } from "$app/navigation";

	import { api } from "$lib/utils/api.svelte.js";

	import { isLoggedIn } from "../utils/utils.svelte";

	import {
		getFeedShown,
		setFeedShown,
		getFeed,
		setFeed,
	} from "$lib/states/feed.svelte.js";

	let feedShown = $derived(getFeedShown());
	let feed = $state([]);
	let loggedInData = $state({});

	const closeMenu = () => {
		const clearedFeed = getFeed().map((item) => ({
			...item,
			highlighted: false,
		}));

		setFeed(clearedFeed);
		setFeedShown(false);
	};

	const getIsLoggedIn = async () => {
		try {
			const response = await isLoggedIn();
			loggedInData.loggedIn = response.userIsLoggedIn;
			loggedInData.verified = response.userIsVerified;
			loggedInData.username = response.username;
		} catch (error) {
			return false;
		}
	};

	onMount(() => {
		feed = [...getFeed()];
		getIsLoggedIn();
	});
</script>

{#if feedShown}
	<div class="fixed inset-0 z-50 flex" transition:fly|global>
		<div class="flex-1 bg-black opacity-25" onclick={closeMenu}></div>
		<div
			class="relative flex h-full w-full transform flex-col bg-white shadow-lg sm:w-2/5"
		>
			<button class="hover:cursor-pointer" onclick={closeMenu}>
				<img class="max-h-8 max-w-8" src={rightArrow} alt="Close" />
			</button>
			<div class="flex flex-1 flex-col overflow-y-auto p-4">
				{#if feed.length > 0}
					{#each feed as item}
						<Entry
							id={item.id}
							entryUsername={item.username}
							currentUsername={loggedInData.username}
							title={item.title}
							address={item.address}
							content={item.content}
							zoningTag={item.tags.find(
								(tag) => tag.classification === "Zoning",
							).name}
							progressTag={item.tags.find(
								(tag) => tag.classification === "Progress",
							).name}
							highlighted={item.highlighted ?? false}
						/>
					{/each}
				{:else}
					<p>No entries found for this area :(</p>
					<p>
						You can add some by joining the BlockTalk community as a
						contributor!
					</p>
				{/if}
			</div>

			<div class="border-t border-gray-200">
				{#if loggedInData.loggedIn && loggedInData.verified}
					<button
						onclick={() => goto("/create-entry")}
						class="block w-full px-4 py-3 text-left transition-colors hover:bg-gray-50"
					>
						Participate
					</button>
				{:else if loggedInData.loggedIn && !loggedInData.verified}
					<button
						onclick={() => goto("/verification-page")}
						class="block w-full px-4 py-3 text-left transition-colors hover:bg-gray-50"
					>
						Get Verified!
					</button>
				{:else}
					<button
						onclick={() => goto("/verification-page")}
						class="block w-full px-4 py-3 text-left font-semibold transition-colors hover:bg-gray-50"
					>
						Login
					</button>
				{/if}
			</div>
		</div>
	</div>
{/if}
