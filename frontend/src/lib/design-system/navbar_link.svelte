<script>
  let { link, linkText, children } = $props();
</script>

<a
  href={link}
  class="w-full px-4 py-3 text-left font-semibold transition-colors hover:bg-gray-50 flex flex-row gap-x-2"
>
  {@render children()}
  <p>{linkText}</p>
</a>
