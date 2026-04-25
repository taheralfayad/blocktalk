import { redirect } from '@sveltejs/kit';
import { isLoggedIn } from '$lib/utils/utils.svelte.js';

export const load = async () => {
  
  const logInData = await isLoggedIn();
  
  if (!!(!logInData.userIsLoggedIn || !logInData.userIsVerified)) {
    redirect(302, '/login');
  }
};
