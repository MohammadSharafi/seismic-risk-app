'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "b0055cb9794e37e74c121735e4def601",
"version.json": "1426d0a6fefa1aed99689be5ae48f068",
"index.html": "7a71bf077dcea0d7f00758fbc3a32e29",
"/": "7a71bf077dcea0d7f00758fbc3a32e29",
"vercel.json": "153fedcff7edfc2ace5d8cb1f3f5701b",
"main.dart.js": "abc69d1d2e852a1cb852e716d18ec457",
"flutter.js": "f393d3c16b631f36852323de8e583132",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "bdd678f10383a1cea4b2e617c941542e",
"assets/AssetManifest.json": "1973c2842f187a22259338be37595e12",
"assets/NOTICES": "ba1cd66458e3609e67e2a557caf4703b",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "a587c72dcd6914e491e4e321fa1c8461",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/packages/flutter_inappwebview_web/assets/web/web_support.js": "509ae636cfdd93e49b5a6eaf0f06d79f",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.css": "5a8d0222407e388155d7d1395a75d5b9",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.html": "16911fcc170c8af1c5457940bd0bf055",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "b6b1f554b282c3a55bc537cd6aaf3b6d",
"assets/fonts/MaterialIcons-Regular.otf": "86bf03d3d01d87047423c4030eb04077",
"assets/assets/hands2.png": "8dd31d7f32a05b08f59260c5fab79ba4",
"assets/assets/fi-rr-calendar.svg": "2326f517b44d2774d350490fa5e6d7ce",
"assets/assets/Group%252020418@2x.png": "e839cc3ff03de1adb501f7b54bccc500",
"assets/assets/check_1.svg": "456cf33d2eed3db265300bafbe0f336a",
"assets/assets/Stressed-2@2x.png": "7d4485b4e78b3da1c1fc1a41564a5a21",
"assets/assets/document.png": "d760ee6998f2396165919049aa156ec9",
"assets/assets/check_2.svg": "d6768af7dc49f8dc5f02f525abd79255",
"assets/assets/check_3.svg": "9db17383db4ff5fc9d89db5da4701903",
"assets/assets/plan_bg.png": "f1c322c4b4ac01fc9d7c8b85dfdcd8d7",
"assets/assets/search_image.png": "8aced0d7ccf468ca6faf04d9f23ae140",
"assets/assets/review_bg.png": "f1c322c4b4ac01fc9d7c8b85dfdcd8d7",
"assets/assets/qrCode.png": "83b97726d5b38c04b5f26eb68d6bb8d2",
"assets/assets/plan_page_animation.json": "1574e0f256068e0baea7917e0ac9a3ec",
"assets/assets/Mood%2520Swings@2x.png": "8ccf67229bde5261dbaad0d31d63f484",
"assets/assets/period_calendar.png": "e4f5a40aab906ac7760468b6e46a549b",
"assets/assets/lightbulb-on.svg": "1c29875b2025979b4368811d74471f23",
"assets/assets/Animation%2520-%25201713705557348.json": "9d12450e9063f2ef473669fd20afa8b4",
"assets/assets/Mask%2520Group%2520709.webp": "cd484ddff621e4c925013983aaee0f38",
"assets/assets/Depressed@2x.png": "0a950302aa64a5a4753e83e8efa3b4f3",
"assets/assets/women.png": "efb8069b4efa245abbb2ec25ed48b830",
"assets/assets/fi-rr-info.svg": "7047c47d38522eabeb84e09d652af697",
"assets/assets/smartphone.png": "6cc96bfc5874cd1eff02333cc352f1aa",
"assets/assets/Video%2520Cover%2520(6)@2x.png": "a883cfc7418036ae9300472f182cd9cd",
"assets/assets/smartphoneV2.png": "4d0f1712f61c72ae5b93d6abfe851f4a",
"assets/assets/check.webp": "f56297f662f0be39f0fc334e5a27dc28",
"assets/assets/analyse-alt.svg": "63707ca3457ef6db8b2b29e0789ae185",
"assets/assets/output-onlinepngtools.png": "6b43db88931c844bf0dd3e3d79e0e172",
"assets/assets/map_vertical.svg": "764b96e6cd567878cb02112d2f84f451",
"assets/assets/doctor_bg.png": "00d0062bdab25d011f0afe98673b15ed",
"assets/assets/end_line.png": "9220b59ec954a5965a21c6afef741fa2",
"assets/assets/march_logo/march_icon.webp": "363e811c73ce0ed9d18dd958d85e6015",
"assets/assets/march_logo/Marchlogotype.svg": "8fe87c373a51714322e1c342124eb6b2",
"assets/assets/doctor_init.png": "8a331b0849554b6bcd18692c78e55c6f",
"assets/assets/32@2x.png": "c6cab4f905ec8c5edb5fe9d2161db856",
"assets/assets/treatment.svg": "128f03b475c5ae88b5ebc4baabeba81e",
"assets/assets/hands.png": "1798d3807aa83053eb94abe428c57b4d",
"assets/assets/Stressed-1@2x.png": "de89cfc4b267f95587a66c289f762282",
"assets/assets/painful-sex.png": "f8a63cd98b4c6ed562281fc0ec223794",
"assets/assets/Stressed@2x.png": "4530847f9e1d6b0d338e2844030aa262",
"assets/assets/program_assets/hr-group%2520(2).svg": "d275fb59bfd8d9d947dbe26e7db87c95",
"assets/assets/program_assets/lesson.svg": "ace101360a1d5424ec413d98a0e5a07b",
"assets/assets/program_assets/user-md-chat%2520(7).svg": "84d6cd8b702ae9a300f4b981716b5d1a",
"assets/assets/program_assets/webinar-play.svg": "936744934da63419fc1d7d265ee540d0",
"assets/assets/program_assets/room-service.svg": "535468a47daa9c80618d039a3b4772aa",
"assets/assets/program_assets/image-removebg-preview%2520(3)@2x.png": "32a314f75d30d2e432f01207fdf63b8f",
"assets/assets/program_assets/file-chart-line%2520(1).svg": "c1cd62e08fab77a8be68e3d930880e93",
"assets/assets/program_assets/analyse-alt%2520(3).svg": "2fa3058fd055d22b5d2dd1b77f550ebd",
"assets/assets/program_assets/treatment%2520(3).svg": "128f03b475c5ae88b5ebc4baabeba81e",
"assets/assets/program_assets/wisdom.svg": "a524990814af582765d8c858e865107f",
"assets/assets/map_horizontal.svg": "f928ae3584c03f71c0b4cf755bb6e902",
"assets/assets/welcome_person.png": "db7c5b91b58b113b7095bd1a64922564",
"assets/assets/fi-rr-angle-left.svg": "359678ec3a2ee0f1a4e9fb7bbc9fc8e4",
"assets/assets/Tired@2x.png": "c4862afdbc8c5e60e42fd6f813a00ff6",
"assets/assets/severity%2520back.webp": "1f1cb2a8421345c531e67571f157fd78",
"assets/assets/productivity.svg": "2f1b7ff706bfdd40ff94e1da965cdd47",
"assets/assets/load_and_check.json": "3f6e1d952442e8321cbff0a5771d6529",
"assets/assets/Image%2520100@2x.png": "0e40001cf1ea80d60c346ab1f0db6de8",
"assets/assets/15@2x.png": "0edbb0b5785af684e3af213fbc929f99",
"assets/assets/selective.png": "8512e2868e8e77aa61a7985ba8da5d86",
"assets/assets/Front%2520-%2520Abdomen%2520and%2520Pelvis@2x.png": "8b47a1c317f3d061400dcaad4e60046d",
"assets/assets/fi-sr-angle-small-down.svg": "a7e480a207c4362852fd03b7ca2f0d17",
"assets/assets/Stressed.png": "a5ce77504418e61191b35ea4ad701a5b",
"canvaskit/skwasm.js": "694fda5704053957c2594de355805228",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/chromium/canvaskit.js": "671c6b4f8fcc199dcc551c7bb125f239",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/canvaskit.js": "66177750aff65a66cb07bb44b8c6422b",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
