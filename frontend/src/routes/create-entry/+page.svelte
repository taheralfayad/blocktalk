<script>
	import { onMount } from "svelte";
	import { LoaderCircle } from "@lucide/svelte";

	import Retvrn from "$lib/components/retvrn.svelte";
	import Input from "$lib/components/input.svelte";
	import SelectInput from "$lib/components/select.svelte";
	import DropdownTextfield from "$lib/components/dropdownTextfield.svelte";
	import Button from "$lib/components/button.svelte";
	import Tags from "$lib/globals/tags.json";

	import { api } from "$lib/utils/api.svelte";
	import { page } from "$app/state";
	import { getFeed, setFeed } from "$lib/states/feed.svelte.js";

	let id = $state(parseInt(page.url.searchParams.get("id") || ""));
	let creatorUsername = $state("");
	let title = $state("");
	let address = $state("");
	let latitude = $state(parseFloat(page.url.searchParams.get("lat")) || "");
	let longitude = $state(parseFloat(page.url.searchParams.get("lng")) || "");
	let zoningTag = $state("");
	let progressTag = $state("");
	let content = $state("");
	let error = $state("");
	let success = $state(false);
	let submitting = $state(false);
	let suggestions = $state([]);
	let isFocused = $state(false);
	let editMode = $state(
		page.url.searchParams.get("edit_mode") === "true" || "",
	);

	const suggestionsHidden = $derived(!isFocused);

	let reverseGeocode = async (lat, lon) => {
		const res = await fetch(
			`https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lon}`,
		);
		const data = await res.json();
		address = data.display_name || `${lat}, ${lon}`;
	};

	onMount(async () => {
		if (latitude && longitude) {
			reverseGeocode(latitude, longitude);
		}
		if (editMode) {
			try {
				let entry = await api.post("/entries/retrieve-entry", {
					id: id,
				});
				title = entry.title;
				address = entry.address;
				latitude = entry.latitude;
				longitude = entry.longitude;
				content = entry.content;
				zoningTag = entry.tags.find(
					(t) => t.classification === "Zoning",
				)?.name;
				progressTag = entry.tags.find(
					(t) => t.classification === "Progress",
				)?.name;
				creatorUsername = entry.username;
				console.log(zoningTag, progressTag);
			} catch (err) {
				console.error(err);
			}
		}
	});

	let handleLocationAutosuggestion = async (event) => {
		if (address.length > 3) {
			const data = await api.get(
				`/entries/autocomplete-address?query=${address}`,
			);

			suggestions = data;
		} else {
			suggestions = [];
		}
	};

	let handleSelectSuggestion = (suggestionName) => {
		const suggestionObject = suggestions.find(
			(suggestion) => suggestion.address == suggestionName,
		);

		address = suggestionObject.address;
		longitude = suggestionObject.lon;
		latitude = suggestionObject.lat;
		suggestions = [];
	};

	let handleGetCurrentLocation = async () => {
		if (!navigator.geolocation) {
			error = "Geolocation is not supported by your browser";
			return;
		}

		try {
			const position = await new Promise((resolve, reject) => {
				navigator.geolocation.getCurrentPosition(resolve, reject);
			});

			const { latitude: lat, longitude: lon } = position.coords;
			latitude = lat;
			longitude = lon;
			await reverseGeocode(lat, lon);
		} catch (err) {
			console.error("Geolocation error:", err);

			if (err.code === 1) {
				error =
					"Location access denied. Please enable location permissions.";
			} else {
				error = "Unable to get your location. Please try again.";
			}
		}
	};

	let handleSubmit = async () => {
		error = "";
		success = false;
		submitting = true;

		const data = {
			title,
			address,
			longitude: longitude || -81.3792,
			latitude: latitude || 28.5383,
			tags: [
				{ name: zoningTag, classification: "Zoning" },
				{ name: progressTag, classification: "Progress" },
			],
			content: content,
		};

		try {
			if (editMode) {
				data["id"] = id;
				const response = await api.post(`/entries/edit-entry`, data);
				let feed = getFeed();

				const updatedFeed = feed.map((item) => {
					if (item.id === id) {
						return {
							id: data.id,
							title: data.title,
							address: data.address,
							content: data.content,
							tags: data.tags,
							longitude: data.longitude,
							latitude: data.latitude,
							username: creatorUsername,
						};
					}
					return item;
				});

				setFeed(updatedFeed);
			} else {
				const response = await api.post(`/entries/create-entry`, data);
			}
			success = true;
		} catch (e) {
			console.error("Submit error:", e);
			if (!error) error = e.message || "An unknown error occurred";
		} finally {
			submitting = false;
		}
	};
</script>

<div class="flex flex-col max-h-screen overflow-y-auto">
	<Retvrn />
	<!--- doing this to force a scrollbar on phones, sorry gods of clean code ---->
	<div class="mb-48">
		<div class="text-center mb-4">
			<h1 class="text-2xl font-semibold">
				{#if editMode}
					Edit
				{:else}
					Add
				{/if}

				an entry — help your neighbor know what's up
			</h1>
		</div>
		<div
			class="flex flex-col justify-center items-center gap-14 overflow-y-auto max-h-screen"
		>
			<form
				onsubmit={handleSubmit}
				class="rounded-2xl border border-slate-100 bg-white p-6 shadow-lg sm:p-8"
			>
				<p class="mb-4 text-sm">
					Share a short title, address and details. Fields marked with <span
						class="font-medium">*</span
					> are required.
				</p>

				<div>
					<Input
						bind:value={title}
						id="title"
						label="Title *"
						placeholder="e.g. Road closed near Elm St."
						class="w-full"
						required
						aria-required="true"
					/>
				</div>

				{#if !editMode}
					<div class="sm:col-span-2">
						<label
							for="address"
							class="mb-1 block text-sm font-medium text-slate-700"
						>
							Location *
						</label>
						<div class="mb-4">
							<DropdownTextfield
								{suggestionsHidden}
								suggestions={suggestions.map(
									(suggestion) => suggestion.address,
								)}
								handleInput={handleLocationAutosuggestion}
								selectSuggestion={handleSelectSuggestion}
								bind:searchValue={address}
								onClickOutside={() => (isFocused = false)}
								onFocus={() => (isFocused = true)}
							/>
						</div>
						<Button
							onClick={() => handleGetCurrentLocation()}
							text="Get Current Location"
						/>
					</div>
				{/if}

				<div class="sm:col-span-2">
					<Input
						bind:value={content}
						id="content"
						label="Description"
						placeholder="Add context, ETA, or contact info..."
						rows={4}
						class="w-full"
						textarea={true}
					/>
				</div>

				<div>
					<SelectInput
						id="progressTagsSelect"
						label="Progress Tag *"
						bind:value={progressTag}
						options={Tags.filter(
							(tag) => tag.classification === "Progress",
						).map((t) => t.name)}
						required={true}
						class="w-full"
						aria-required="true"
					/>
				</div>

				<div>
					<SelectInput
						id="zoningTagsSelect"
						label="Zoning Tag *"
						bind:value={zoningTag}
						options={Tags.filter(
							(tag) => tag.classification === "Zoning",
						).map((t) => t.name)}
						required={true}
						class="w-full"
						aria-required="true"
					/>
				</div>

				<div class="mt-5 flex items-center justify-between gap-4">
					<div>
						{#if error}
							<p class="text-sm text-red-600" role="alert">
								{error}
							</p>
						{/if}
						{#if success}
							<p class="text-sm text-green-700" role="status">
								Saved ✓
							</p>
						{/if}
					</div>

					<div class="ml-auto flex items-center gap-3">
						<button
							type="submit"
							class="inline-flex items-center gap-2 rounded-xl bg-sky-600 px-4 py-2 font-medium
                   text-white shadow-sm hover:cursor-pointer hover:bg-sky-700 focus:outline-none focus-visible:ring-4
                   focus-visible:ring-sky-200 active:scale-98"
							aria-disabled={submitting}
							disabled={submitting}
						>
							{#if submitting}
								<LoaderCircle class="h-4 w-4 animate-spin" />
								Saving...
							{:else}
								Submit
							{/if}
						</button>

						<button
							type="button"
							class="rounded-lg border border-slate-200 px-3 py-2 text-sm text-slate-700 hover:cursor-pointer hover:bg-slate-50"
							onclick={() => {
								id = "";
								title = "";
								address = "";
								lattitude = "";
								longitude = "";
								content = "";
								progressTag = "";
								zoningTag = "";
								error = "";
								success = false;
								editMode = false;
							}}
						>
							Reset
						</button>
					</div>
				</div>
			</form>
		</div>
	</div>
</div>
