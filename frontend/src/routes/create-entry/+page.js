import { redirect } from '@sveltejs/kit';
import { isLoggedIn } from '$lib/utils/utils.svelte.js';

export const load = async () => {
  if (!(await isLoggedIn())) {
    redirect(302, '/login');
  }
};
