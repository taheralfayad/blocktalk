<script lang="ts">
  import Entry from "$lib/components/entry.svelte";
  import rightArrow from "$lib/assets/right.svg";
  import { fly } from "svelte/transition";

  import { isLoggedIn } from "../utils/utils.svelte";

  import {
    getFeedShown,
    setFeedShown,
    getFeed,
    setFeed,
  } from "$lib/states/feed.svelte.js";

  import NavbarLink from "$lib/design-system/navbar_link.svelte";

  import { Check, LogIn, Smile, MapPinPlus } from "@lucide/svelte";

  let feedShown = $derived(getFeedShown());
  let feed: any[] = $state([]);

  const closeMenu = () => {
    const clearedFeed = getFeed().map((item) => ({
      ...item,
      highlighted: false,
    }));

    setFeed(clearedFeed);
    setFeedShown(false);
  };
  let loggedIn = $state(false);
  let verified = $state(false);

  const getIsLoggedIn = async () => {
    try {
      const loggedInData = await isLoggedIn();
      loggedIn = loggedInData.userIsLoggedIn;
      verified = loggedInData.userIsVerified;
    } catch (error) {
      return false;
    }
  };

  $effect(() => {
    feed = getFeed();
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
        {#if loggedIn && verified}
          <NavbarLink link="/create-entry" linkText="Participate">
            <MapPinPlus />
          </NavbarLink>
        {:else if loggedIn && !verified}
          <NavbarLink link="/verification-page" linkText="Get Verified!">
            <Check />
          </NavbarLink>
        {:else}
          <NavbarLink link="/login" linkText="Login">
            <LogIn />
          </NavbarLink>
        {/if}

        {#if loggedIn}
          <NavbarLink link="/user-profile" linkText="My Profile">
            <Smile />
          </NavbarLink>
        {/if}
      </div>
    </div>
  </div>
{/if}
