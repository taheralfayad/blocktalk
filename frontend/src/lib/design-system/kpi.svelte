<script>
  let { value, title } = $props();
</script>

<div class="border rounded-md items-center justify-center bg-slate-300">
  <div class="flex flex-col p-24 justify-center items-center">
    <h2 class="text-xl">{value}</h2>
    <p>{title}</p>
  </div>
</div>
