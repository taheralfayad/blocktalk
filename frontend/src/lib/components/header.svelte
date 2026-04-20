<script>
  import Banner from "../design-system/banner.svelte";
  import SearchBar from "../design-system/searchBar.svelte";
  import Feed from "../components/feed.svelte";

  import Logo from "$lib/assets/transparent-logo.svg";

  import { getFeedShown, setFeedShown } from "$lib/states/feed.svelte.js";

  let feedShown = $derived(getFeedShown());
</script>

<div class="flex min-h-16 items-center justify-between p-2 shadow-sm gap-4">
  <div class="flex max-h-6 w-28 items-center justify-center">
    <img class="max-w-28" src={Logo} alt="Logo" />
  </div>

  <SearchBar />

  <button
    onclick={() => setFeedShown(true)}
    class="
      hidden
      md:block
      text-black-200
      flex items-center gap-2
      rounded-md bg-slate-300
      px-6
      py-2
      font-medium
      transition
      hover:cursor-pointer
      hover:bg-slate-400
      focus:ring-2
      focus:ring-cyan-300
    "
  >
    <span>Feed</span>
  </button>

  <button
    onclick={() => setFeedShown(true)}
    class="
      md:hidden
      py-2
      hover:cursor-pointer
    "
    aria-label="Feed"
  >
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
      class="lucide lucide-rss-icon lucide-rss"
      ><path d="M4 11a9 9 0 0 1 9 9" /><path
        d="M4 4a16 16 0 0 1 16 16"
      /><circle cx="5" cy="19" r="1" /></svg
    >
  </button>

  {#if feedShown}
    <Feed />
  {/if}
</div>
