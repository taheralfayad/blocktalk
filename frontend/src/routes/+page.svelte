<script>
  import Header from "$lib/components/header.svelte";
  import debounce from "lodash/debounce";
  import { onMount, onDestroy } from "svelte";
  import { setFeed } from "$lib/states/feed.svelte.js";
  import { initMap, getMap } from "$lib/states/map.svelte.js";

  import { api } from "$lib/utils/api.svelte.js";
  import { isLoggedIn } from "$lib/utils/utils.svelte.js";
  import { goto } from "$app/navigation";

  let refreshToken = async () => {
    try {
      await api.post("/users/refresh-token");
    } catch (err) {
      console.error("Error refreshing token:", err);
    }
  };

  let retrieveEntries = async (data) => {
    try {
      const response = await api.post(
        "/entries/retrieve-entries-within-visible-bounds",
        data,
      );
      setFeed(response);
    } catch (error) {}
  };

  onMount(() => {
    refreshToken();
    initMap("map");

    const mapInstance = getMap();

    const MIN_QUERY_ZOOM = 8;

    const handleMovement = debounce(() => {
      const zoom = mapInstance.getZoom();

      if (zoom < MIN_QUERY_ZOOM) {
        console.log("Zoomed out too far — skipping query");
        setFeed([]);
        return;
      }

      const bounds = mapInstance.getBounds();

      const data = {
        north: bounds.getNorth(),
        south: bounds.getSouth(),
        east: bounds.getEast(),
        west: bounds.getWest(),
      };

      retrieveEntries(data);
    }, 1500);

    mapInstance.on("click", async (e) => {
      const { lng, lat } = e.lngLat;

      if (await isLoggedIn()) {
        goto(`/create-entry?lat=${lat}&lng=${lng}`);
      } else {
        console.log("fuck you");
      }
    });

    mapInstance.on("load", () => {
      mapInstance.resize();

      mapInstance.on("zoomend", () => {
        handleMovement();
      });
      mapInstance.on("moveend", () => {
        console.log("hello?");
        handleMovement();
      });

      handleMovement();
    });

    onDestroy(() => {
      destroyMap();
    });
  });
</script>

<div class="flex h-screen flex-col">
  <Header />
  <div id="map" class="relative min-h-0 min-w-0 flex-1"></div>
</div>
