<script>
  import { goto } from "$app/navigation";

  import Input from "$lib/components/login/input.svelte";
  import Retvrn from "$lib/components/retvrn.svelte";

  import { api } from "$lib/utils/api.svelte";

  let isLogin = $state(true);
  let username = $state("");
  let email = $state("");
  let password = $state("");
  let firstName = $state("");
  let lastName = $state("");
  let phoneNumber = $state("");
  let confirmPassword = $state("");
  let errorMessage = $state("");
  let isLoading = $state(false);
  let verificationChoice = $state("email");

  const handleSubmit = async (event) => {
    event.preventDefault();

    errorMessage = "";
    isLoading = true;

    try {
      let data = {};

      if (isLogin) {
        data = {
          username,
          password,
        };

        await api.post("/users/login", data);

        goto("/");
      } else {
        if (password !== confirmPassword) {
          errorMessage = "Passwords do not match";
          isLoading = false;
          return;
        }

        if (
          verificationChoice === "phoneNumber" &&
          !/^\+[1-9]\d{1,14}$/.test(phoneNumber)
        ) {
          errorMessage =
            "Phone number must be in E.164 format (e.g. +12345678910)";
          isLoading = false;
          return;
        }

        data = {
          username,
          first_name: firstName,
          last_name: lastName,
          password,
        };

        if (verificationChoice === "phoneNumber") {
          data.phone_number = phoneNumber;
        } else {
          data.email = email;
        }

        await api.post("/users/create-user", data);

        goto("/");
      }
    } catch (err) {
      console.error(err);

      if (err.status === 400) {
        errorMessage = err.data?.message || "Invalid input.";
      } else if (err.status === 401) {
        errorMessage = "Invalid username or password.";
      } else if (err.status === 409) {
        errorMessage = "User already exists.";
      } else if (err.status === 500 && err.data) {
        errorMessage = err.data.error;
      } else {
        errorMessage = "Something went wrong. Please try again.";
      }
    } finally {
      isLoading = false;
    }
  };

  function toggleMode() {
    isLogin = !isLogin;
    confirmPassword = "";
  }
</script>

<div class="flex flex-col min-h-screen">
  <Retvrn />
  <div
    class="flex flex-1 items-start justify-center bg-white p-4 pb-8 overflow-y-auto max-h-screen"
  >
    <div class="w-full max-w-md">
      <div class="border border-black p-8">
        <h1 class="mb-6 text-center text-2xl font-bold">
          {isLogin ? "Login" : "Sign Up"}
        </h1>
        {#if errorMessage}
          <div
            class="mb-4 border border-red-500 bg-red-100 px-3 py-2 text-sm text-red-700"
          >
            {errorMessage}
          </div>
        {/if}

        <form onsubmit={handleSubmit} class="space-y-4">
          <Input id="username" bind:value={username} label="Username" />
          <div>
            <label for="password" class="mb-1 block text-sm font-medium">
              Password
            </label>
            <input
              type="password"
              id="password"
              bind:value={password}
              class="w-full border border-black px-3 py-2 focus:ring-1 focus:ring-black focus:outline-none"
              required
            />
            {#if !isLogin}
              <small>minimum 8 characters</small>
            {/if}
          </div>

          {#if !isLogin}
            <div>
              <Input
                type="password"
                id="confirmPassword"
                bind:value={confirmPassword}
                label="Confirm Password"
              />
              <Input bind:value={firstName} id="firstName" label="First Name" />
              <Input bind:value={lastName} id="lastName" label="Last Name" />
              <fieldset>
                <legend>Select a verification method</legend>
                <div>
                  <input
                    type="radio"
                    id="email"
                    name="verificationMethod"
                    value="email"
                    bind:group={verificationChoice}
                    checked
                  />
                  <label for="email">Email</label>
                </div>
                <div>
                  <input
                    type="radio"
                    id="phoneNumber"
                    name="verificationMethod"
                    value="phoneNumber"
                    bind:group={verificationChoice}
                  />
                  <label for="phoneNumber">Phone Number</label>
                </div>
              </fieldset>
              {#if verificationChoice === "email"}
                <Input
                  type="email"
                  bind:value={email}
                  id="email"
                  label="Email"
                />
              {:else if verificationChoice === "phoneNumber"}
                <Input
                  type="tel"
                  id="phoneNumber"
                  bind:value={phoneNumber}
                  label="Phone Number"
                />
                <small>eg. +12345678910</small>
              {/if}
            </div>
          {/if}

          <button
            type="submit"
            disabled={isLoading}
            class="w-full border border-black bg-black px-4 py-2 text-white transition-colors hover:bg-white hover:text-black disabled:opacity-50"
          >
            {isLoading ? "Please wait..." : isLogin ? "Login" : "Sign Up"}
          </button>
        </form>

        <div class="mt-6 text-center">
          <button
            onclick={toggleMode}
            class="on:cursor-pointer text-sm hover:underline"
          >
            {isLogin
              ? "Don't have an account? Sign up"
              : "Already have an account? Login"}
          </button>
        </div>
      </div>
    </div>
  </div>
</div>
