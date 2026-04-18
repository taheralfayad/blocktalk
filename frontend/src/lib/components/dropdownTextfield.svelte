<script>
  import Input from "$lib/components/input.svelte";
  import { clickOutside } from "$lib/actions/clickOutside.svelte";

  let {
    suggestionsHidden,
    suggestions,
    handleInput,
    selectSuggestion,
    onFocus,
    onClickOutside,
    searchValue = $bindable(),
  } = $props();
</script>

<div class="relative w-full max-w-md" use:clickOutside={onClickOutside}>
  <Input
    bind:value={searchValue}
    id="searchBar"
    placeholder="Find a city"
    {handleInput}
    {onFocus}
  />

  {#if !suggestionsHidden && suggestions.length}
    <ul
      class="
        absolute left-0 right-0 mt-1
        bg-white
        rounded-xl
        border border-gray-200
        shadow-lg
        max-h-56 overflow-y-auto
        z-50
      "
    >
      {#each suggestions as suggestion}
        <li
          class="
            px-4 py-2 text-sm text-gray-700
            cursor-pointer transition
            hover:bg-blue-50 hover:text-blue-700
            active:bg-blue-100
          "
          role="option"
          tabindex="0"
          onclick={() => selectSuggestion(suggestion)}
        >
          {suggestion}
        </li>
      {/each}
    </ul>
  {/if}
</div>
