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
- [x] 1. Init pnpm workspace + Turborepo
- [x] 2. Create packages/shared — TypeScript interfaces (Week, Meal, GroceryItem, User, Household, PubSub event types, API request/response types)
- [x] 3. Root tooling: tsconfig base (strict), ESLint (eslint-config-typescript), Prettier, .gitignore
- [x] 4. Create README.md and CONTRIBUTING.md

### Phase 1: Infrastructure (Bicep)
- [ ] 5. Bicep module: Cosmos DB (serverless, NoSQL API) — 5 containers with partition keys
- [ ] 6. Bicep module: Azure Functions App (Node.js 20 LTS)
- [ ] 7. Bicep module: Azure Web PubSub (Free tier)
- [ ] 8. Bicep module: Azure Static Web Apps (linked to Functions)
- [ ] 9. Bicep module: Azure Key Vault (store Cosmos connection string, PubSub connection string)
- [ ] 10. Bicep module: App Registration (personal MS accounts, redirect URIs)
- [ ] 11. Parameters files for dev + prod
- [ ] 12. GitHub Actions workflow: deploy-infra.yml (manual trigger + on infra changes)

### Phase 2: Azure App Registration
- [ ] 13. App registration: personal accounts (consumers tenant), expose API scope (access_as_user)
- [ ] 14. SPA redirect URIs for localhost + SWA prod URLs

### Phase 3: Backend (Azure Functions v4, TypeScript)
- [ ] 15. Functions project scaffold (apps/api) — @azure/functions v4 programming model
- [ ] 16. MSAL token validation middleware — validates Bearer token, extracts userId/email from claims
- [ ] 17. Cosmos DB client module — thin repositories per container (upsert/find/delete helpers)
- [ ] 18. User auto-provisioning — on first auth, create User record linked to pre-seeded householdId
- [ ] 19. Household membership validation — middleware checks user.householdId before all resource operations
- [ ] 20. Web PubSub publisher utility — publish event to week group (fire-and-forget, swallow errors)
- [ ] 21. Negotiate endpoint: GET /api/pubsub/negotiate — returns signed connection URL for client
- [ ] 22. Week endpoints: GET /api/weeks, POST /api/weeks, GET /api/weeks/{id}, POST /api/weeks/{id}/duplicate
- [ ] 23. Meal endpoints: POST /api/weeks/{id}/meals, PATCH /api/meals/{id}, DELETE /api/meals/{id}
- [ ] 24. Grocery item endpoints: POST /api/weeks/{id}/items, PATCH /api/items/{id}, DELETE /api/items/{id}
- [ ] 25. Retention timer function — weekly trigger, deletes weeks beyond 36, cascades to Meals + GroceryItems
- [ ] 26. Local dev config: Cosmos emulator connection string in local.settings.json, stub PubSub publisher

### Phase 4: Frontend — Core (apps/web)
- [ ] 27. Vite scaffold with vite-plugin-pwa, React 18, TypeScript strict
- [ ] 28. MSAL configuration — PublicClientApplication with consumers authority, loginRedirect flow
- [ ] 29. Tailwind CSS + shadcn/ui setup (init, theme tokens)
- [ ] 30. TanStack Query provider + queryClient (staleTime, retry config)
- [ ] 31. Zustand store slices: authStore (user), uiStore (current weekId, active filter, connection status), offlineQueueStore
- [ ] 32. React Router: routes — /login, /, /weeks/:weekId

### Phase 5: Frontend — Features
- [ ] 33. Auth flow: login page, AuthGuard wrapper, token acquisition silently on API calls
- [ ] 34. Layout shell: two-pane desktop (ResizablePanelGroup), single-pane mobile with collapsible meals section (shadcn/Collapsible)
- [ ] 35. Week selector: navigation arrows (prev/next week) + dropdown list of 36 weeks; "current week" = most recent by startDate
- [ ] 36. Week management: create new week (auto-label "Week of YYYY-MM-DD"), duplicate past week
- [ ] 37. Meals panel: add/edit/delete (inline editing), drag-and-drop reorder via @dnd-kit/sortable; PATCH order on drop
- [ ] 38. Grocery list panel: add item (React Hook Form), inline edit, swipe-to-complete on mobile (tap toggle), filter tabs (All / Remaining / Completed)
- [ ] 39. Real-time: connect to Web PubSub via @azure/web-pubsub-client, join week group on weekId change, dispatch TanStack Query invalidations on events

### Phase 6: Offline Support
- [ ] 40. Service worker via vite-plugin-pwa (Workbox) — CacheFirst for app shell assets, NetworkFirst with IndexedDB fallback for API responses
- [ ] 41. Offline mutation queue — persisted to IndexedDB via idb library; operations: {id (uuid), type, payload, timestamp, retries}
- [ ] 42. Optimistic UI — mutations applied immediately to TanStack Query cache; queued if navigator.onLine === false
- [ ] 43. Reconnect handler — on online event: flush queue in insertion order; last-write-wins (no merge); remove on success, increment retries on failure (max 3, then discard)
- [ ] 44. PubSub reconnect — Web PubSub client SDK has built-in reconnect; rejoin week group after reconnect
- [ ] 45. Connection status indicator — banner/badge in header reflecting online/offline + sync state

### Phase 7: CI/CD (GitHub Actions)
- [ ] 46. deploy-api.yml — on push to main (apps/api changes), build + deploy to Azure Functions
- [ ] 47. deploy-web.yml — on push to main (apps/web changes), build PWA + deploy to Azure Static Web Apps via azure/static-web-apps-deploy action
- [ ] 48. Environment secrets in GitHub: AZURE_CREDENTIALS, COSMOS_CONNECTION_STRING, PUBSUB_CONNECTION_STRING, SWA_DEPLOYMENT_TOKEN

### Phase 8: Testing
- [ ] 49. Backend unit tests (Vitest): token validation middleware, Cosmos repository helpers, retention job logic, PubSub publisher (mock)
- [ ] 50. Frontend component tests (Vitest + RTL): GroceryList (add/toggle/filter), MealsList (add/delete/reorder), WeekSelector, AuthGuard
- [ ] 51. Mock MSAL in tests using @azure/msal-browser test utilities or manual mock
- [ ] 52. Mock TanStack Query in component tests via QueryClientProvider with test client

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
