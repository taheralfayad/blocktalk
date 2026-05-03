<script>
  import Kpi from "$src/lib/design-system/kpi.svelte";
  import Retvrn from "$src/lib/components/retvrn.svelte";

  import { onMount } from "svelte";

  import { api } from "$src/lib/utils/api.svelte";

  const retrieveUserStats = async () => {
    try {
      const response = await api.get("/entries/user-stats");
      username = response.username;
      stats = response.stats;
    } catch (err) {
      console.error(err);
    }
  };

  let username = $state("");
  let stats = $state({});

  onMount(() => {
    retrieveUserStats();
  });
</script>

<Retvrn />
<div class="flex flex-col min-h-screen justify-start items-center gap-8">
  <h1 class="text-2xl">Hey Blocktalker @{username}!</h1>
  <p>
    Thanks for helping us track development data around the world! Here's a peek
    at what your contributions look like:
  </p>
  <div class="flex flex-row gap-8">
    {#each stats as stat}
      <Kpi title={stat.title} value={stat.value} />
    {/each}
  </div>
</div>
