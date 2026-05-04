# Plan: Plantry App 2 — Implementation

## Decisions recorded
- Language: TypeScript strict everywhere
- Frontend: Vite + TanStack Query + Zustand + Tailwind CSS + shadcn/ui + React Hook Form + Vitest + RTL
- Repo: Monorepo (pnpm workspaces + Turborepo) — apps/web, apps/api, packages/shared
- Azure account type: Personal Microsoft accounts only (authority: login.microsoftonline.com/consumers)
- Household: Pre-seeded single household in Cosmos DB; all authed users auto-assigned
- IaC: Bicep; CI/CD: GitHub Actions
- Frontend hosting: Azure Static Web Apps (standalone Functions app for API)
- Offline conflict: Last-write-wins
- Meal reordering: Drag-and-drop via @dnd-kit
- Local dev: Cosmos DB emulator + mock PubSub; real Azure for dev/prod
- Environments: dev + prod
- Testing: Unit + component tests (no E2E for v1)

## Partition key strategy
- Users: /id
- Households: /id
- Weeks: /householdId
- Meals: /weekId
- GroceryItems: /weekId

## Plan

### Phase 0: Monorepo Foundation
1. Init pnpm workspace + Turborepo
2. Create packages/shared — TypeScript interfaces (Week, Meal, GroceryItem, User, Household, PubSub event types, API request/response types)
3. Root tooling: tsconfig base (strict), ESLint (eslint-config-typescript), Prettier, .gitignore

### Phase 1: Infrastructure (Bicep)
4. Bicep module: Cosmos DB (serverless, NoSQL API) — 5 containers with partition keys
5. Bicep module: Azure Functions App (Node.js 20 LTS)
6. Bicep module: Azure Web PubSub (Free tier)
7. Bicep module: Azure Static Web Apps (linked to Functions)
8. Bicep module: Azure Key Vault (store Cosmos connection string, PubSub connection string)
9. Bicep module: App Registration (personal MS accounts, redirect URIs)
10. Parameters files for dev + prod
11. GitHub Actions workflow: deploy-infra.yml (manual trigger + on infra changes)

### Phase 2: Azure App Registration
12. App registration: personal accounts (consumers tenant), expose API scope (access_as_user)
13. SPA redirect URIs for localhost + SWA prod URLs

### Phase 3: Backend (Azure Functions v4, TypeScript)
14. Functions project scaffold (apps/api) — @azure/functions v4 programming model
15. MSAL token validation middleware — validates Bearer token, extracts userId/email from claims
16. Cosmos DB client module — thin repositories per container (upsert/find/delete helpers)
17. User auto-provisioning — on first auth, create User record linked to pre-seeded householdId
18. Household membership validation — middleware checks user.householdId before all resource operations
19. Web PubSub publisher utility — publish event to week group (fire-and-forget, swallow errors)
20. Negotiate endpoint: GET /api/pubsub/negotiate — returns signed connection URL for client
21. Week endpoints: GET /api/weeks, POST /api/weeks, GET /api/weeks/{id}, POST /api/weeks/{id}/duplicate
22. Meal endpoints: POST /api/weeks/{id}/meals, PATCH /api/meals/{id}, DELETE /api/meals/{id}
23. Grocery item endpoints: POST /api/weeks/{id}/items, PATCH /api/items/{id}, DELETE /api/items/{id}
24. Retention timer function — weekly trigger, deletes weeks beyond 36, cascades to Meals + GroceryItems
25. Local dev config: Cosmos emulator connection string in local.settings.json, stub PubSub publisher

### Phase 4: Frontend — Core (apps/web)
26. Vite scaffold with vite-plugin-pwa, React 18, TypeScript strict
27. MSAL configuration — PublicClientApplication with consumers authority, loginRedirect flow
28. Tailwind CSS + shadcn/ui setup (init, theme tokens)
29. TanStack Query provider + queryClient (staleTime, retry config)
30. Zustand store slices: authStore (user), uiStore (current weekId, active filter, connection status), offlineQueueStore
31. React Router: routes — /login, /, /weeks/:weekId

### Phase 5: Frontend — Features
32. Auth flow: login page, AuthGuard wrapper, token acquisition silently on API calls
33. Layout shell: two-pane desktop (ResizablePanelGroup), single-pane mobile with collapsible meals section (shadcn/Collapsible)
34. Week selector: navigation arrows (prev/next week) + dropdown list of 36 weeks; "current week" = most recent by startDate
35. Week management: create new week (auto-label "Week of YYYY-MM-DD"), duplicate past week
36. Meals panel: add/edit/delete (inline editing), drag-and-drop reorder via @dnd-kit/sortable; PATCH order on drop
37. Grocery list panel: add item (React Hook Form), inline edit, swipe-to-complete on mobile (tap toggle), filter tabs (All / Remaining / Completed)
38. Real-time: connect to Web PubSub via @azure/web-pubsub-client, join week group on weekId change, dispatch TanStack Query invalidations on events

### Phase 6: Offline Support
39. Service worker via vite-plugin-pwa (Workbox) — CacheFirst for app shell assets, NetworkFirst with IndexedDB fallback for API responses
40. Offline mutation queue — persisted to IndexedDB via idb library; operations: {id (uuid), type, payload, timestamp, retries}
41. Optimistic UI — mutations applied immediately to TanStack Query cache; queued if navigator.onLine === false
42. Reconnect handler — on online event: flush queue in insertion order; last-write-wins (no merge); remove on success, increment retries on failure (max 3, then discard)
43. PubSub reconnect — Web PubSub client SDK has built-in reconnect; rejoin week group after reconnect
44. Connection status indicator — banner/badge in header reflecting online/offline + sync state

### Phase 7: CI/CD (GitHub Actions)
45. deploy-api.yml — on push to main (apps/api changes), build + deploy to Azure Functions
46. deploy-web.yml — on push to main (apps/web changes), build PWA + deploy to Azure Static Web Apps via azure/static-web-apps-deploy action
47. Environment secrets in GitHub: AZURE_CREDENTIALS, COSMOS_CONNECTION_STRING, PUBSUB_CONNECTION_STRING, SWA_DEPLOYMENT_TOKEN

### Phase 8: Testing
48. Backend unit tests (Vitest): token validation middleware, Cosmos repository helpers, retention job logic, PubSub publisher (mock)
49. Frontend component tests (Vitest + RTL): GroceryList (add/toggle/filter), MealsList (add/delete/reorder), WeekSelector, AuthGuard
50. Mock MSAL in tests using @azure/msal-browser test utilities or manual mock
51. Mock TanStack Query in component tests via QueryClientProvider with test client

## Relevant files to create
- `pnpm-workspace.yaml`
- `turbo.json`
- `tsconfig.base.json`
- `packages/shared/src/types/` — data models, API types, PubSub event types
- `infra/` — Bicep modules per resource
- `apps/api/` — Azure Functions project
- `apps/web/` — Vite PWA React app
- `.github/workflows/` — CI/CD

## Verification
1. `pnpm build` in root completes without errors
2. Cosmos DB emulator: CRUD operations on all 5 containers work via Functions locally
3. Auth: MSAL login with personal Microsoft account succeeds, token validated by backend
4. Real-time: item toggle on one browser tab reflects instantly in another tab (same week group)
5. Offline: disconnect network, add/toggle items, reconnect — changes sync to backend, no data loss
6. Drag-drop: reorder meals, verify order persisted after page reload
7. Duplicate week: meals copied, grocery items copied with completed=false
8. Retention job: manual trigger deletes weeks beyond 36
9. Mobile layout: grocery list dominates, meals collapsible; large tap targets
10. Tests pass: `pnpm test` in root
