<script>
  import Retvrn from "$src/lib/components/retvrn.svelte";
</script>

<div>
  <Retvrn />
  <div class="flex flex-col items-center justify-center min-h-screen p-8">
    <div class="max-w-lg text-center space-y-6">
      <h1 class="text-3xl font-bold text-slate-800">Welcome to Blocktalk!</h1>

      <p class="text-slate-600 leading-relaxed">
        Thanks for signing up! To ensure we're providing the highest quality
        contributions, please verify your account in our Discord community.
      </p>

      <div class="bg-white rounded-lg border border-slate-200 p-6 text-left">
        <h2 class="text-lg font-semibold text-slate-700 mb-4">
          How to get verified:
        </h2>

        <ol class="list-decimal list-inside space-y-3 text-slate-600">
          <li>
            Join our Discord:
            <a
              href="https://discord.gg/X7WfnCFCgu"
              class="text-blue-600 hover:underline">discord.gg/X7WfnCFCgu</a
            >
          </li>
          <li>
            Introduce yourself in #general, tell us your username and share your
            city
          </li>
          <li>One of our admins will verify you</li>
          <li>After verification, you can start contributing!</li>
        </ol>
      </div>
    </div>
  </div>
</div>
