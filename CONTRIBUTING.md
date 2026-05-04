# Contributing to Plantry App 2

Thank you for contributing! This document covers how to set up a local development environment, the project conventions, and the pull-request workflow.

Before diving in, please read the documents in `docs/` to understand the product and architecture:

- [`docs/requirements.md`](docs/requirements.md) – what the app must do and why
- [`docs/architecture.md`](docs/architecture.md) – how the system is designed
- [`docs/plan.md`](docs/plan.md) – phased delivery plan and progress tracking

---

## Prerequisites

| Tool | Minimum version | Installation |
|---|---|---|
| Node.js | 20 LTS | https://nodejs.org |
| pnpm | 9 | `npm install -g pnpm` |
| Azure CLI | latest | https://learn.microsoft.com/cli/azure/install-azure-cli |
| Azure Functions Core Tools | v4 | https://learn.microsoft.com/azure/azure-functions/functions-run-local |
| Azure Cosmos DB Emulator | latest | https://learn.microsoft.com/azure/cosmos-db/local-emulator |

---

## Repository layout

```
plantry-app2/
├── apps/
│   ├── api/          # Azure Functions backend (TypeScript)
│   └── web/          # React PWA frontend (Vite + TypeScript)
├── packages/
│   └── shared/       # Shared TypeScript types (models, API, PubSub events)
├── infra/            # Bicep infrastructure-as-code modules
├── .github/
│   └── workflows/    # GitHub Actions CI/CD pipelines
├── docs/             # Requirements, architecture, delivery plan
├── turbo.json        # Turborepo task pipeline
├── pnpm-workspace.yaml
└── tsconfig.base.json
```

---

## Local development setup

### 1. Install dependencies

```bash
pnpm install
```

### 2. Start the Cosmos DB Emulator

Follow the [official guide](https://learn.microsoft.com/azure/cosmos-db/local-emulator) to start the emulator.

Notes for installation on Ubuntu 24.04 (Noble) running in Windows System for Linux2 (WSL2):
- Docker Installation into Ubuntu WSL2: https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
- Emulator container installation: https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-develop-emulator#install-the-emulator

The default endpoint is `https://localhost:8081` with a UX exposed at `https://localhost:8081/_explorer/index.html`


Seed the five containers (`Users`, `Households`, `Weeks`, `Meals`, `GroceryItems`) and the pre-seeded household document before running the API.

### 3. Configure the API

Copy the template and fill in the emulator values:

```bash
cp apps/api/local.settings.json.example apps/api/local.settings.json
```

Key values to set:

| Setting | Value for local dev |
|---|---|
| `COSMOS_CONNECTION_STRING` | Cosmos emulator connection string |
| `PUBSUB_CONNECTION_STRING` | Leave as `mock` — the stub publisher logs to console |
| `AZURE_CLIENT_ID` | App registration client ID |
| `HOUSEHOLD_ID` | Pre-seeded household document ID |

### 4. Start the API

```bash
cd apps/api
pnpm start   # runs: func start
```

The Functions host listens on `http://localhost:7071`.

### 5. Start the web app

```bash
cd apps/web
pnpm dev     # runs: vite
```

The dev server listens on `http://localhost:5173`.

Open `http://localhost:5173` in your browser and sign in with a personal Microsoft account.

---

## Common tasks

| Task | Command (from repo root) |
|---|---|
| Build all packages | `pnpm build` |
| Run all tests | `pnpm test` |
| Lint all packages | `pnpm lint` |
| Format code | `pnpm format` |
| Build a single package | `pnpm --filter @plantry/shared build` |

---

## Coding conventions

- **TypeScript strict mode everywhere** — no `any`, no implicit `undefined`.
- Import shared types from `@plantry/shared`, never duplicate them.
- Backend functions follow the **Azure Functions v4 programming model** (named exports, not class-based).
- Frontend state lives in **Zustand** stores; server state is managed by **TanStack Query**.
- UI components use **shadcn/ui** primitives styled with **Tailwind CSS**.
- All mutations apply **optimistic updates** to the TanStack Query cache before the API call completes.

---

## Pull-request workflow

1. **Branch from `main`** using the naming convention `feat/<short-description>` or `fix/<short-description>`.
2. Keep PRs focused — one feature or fix per PR.
3. Ensure `pnpm build` and `pnpm test` pass locally before opening a PR.
4. Reference the relevant item from [`docs/plan.md`](docs/plan.md) in the PR description.
5. Update `docs/plan.md` to check off any plan items completed by the PR.
6. Request review from at least one other contributor before merging.

---

## Environment secrets

Never commit secrets. The following values must be stored in GitHub Secrets for CI/CD and in `apps/api/local.settings.json` (git-ignored) for local dev:

- `AZURE_CREDENTIALS`
- `COSMOS_CONNECTION_STRING`
- `PUBSUB_CONNECTION_STRING`
- `SWA_DEPLOYMENT_TOKEN`
- `AZURE_CLIENT_ID`
- `HOUSEHOLD_ID`
