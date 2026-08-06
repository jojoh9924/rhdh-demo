# ${{ values.pluginName }}

A Backstage ${{ values.pluginType }} plugin for Red Hat Developer Hub.

## Getting Started

This plugin was scaffolded using the Plugin Creator template. The repository includes a `devfile.yaml` that provisions a complete development environment in OpenShift Dev Spaces with:

- **tools container** — Node.js, TypeScript, Yarn for plugin development
- **rhdh container** — a real RHDH 1.10 instance for integration testing

### Open in Dev Spaces

Click **"Open in Dev Spaces"** from the RHDH catalog, or navigate directly to:

```
${{ values.devSpacesUrl }}/#https://github.com/${{ values.destination.owner }}/${{ values.destination.repo }}
```

When the workspace starts, RHDH boots automatically in the background.

## Development Workflows

This workspace supports two approaches. Use whichever fits your needs.

### Approach A: Standalone Plugin (default)

The scaffolded plugin is ready to develop immediately. Use the IDE task menu (Terminal → Run Task):

| Task | What it does |
|------|--------------|
| **1. Install dependencies** | `yarn install` in the plugin directory |
| **2. Deploy plugin to RHDH** | Exports the dynamic plugin and copies it into the RHDH plugins volume |
| **3. Restart RHDH** | Reloads RHDH to pick up the deployed plugin |
| **4. Run tests** | Executes the plugin test suite |
| **5. Push branch & create PR** | Commits, pushes, and opens a pull request via `gh` CLI |
| **(Optional) Start standalone dev server** | Hot-reloading dev server on port 3000 for isolated UI development |

**Typical loop:**

1. Write plugin code in `src/`
2. Run `yarn start` for fast feedback with hot-reload (port 3000)
3. When ready to test in RHDH, run task **2** then **3**
4. Verify your plugin at the RHDH endpoint (port 7007)
5. Ship with task **5**

### Approach B: Full Backstage App (RHDH docs workflow)

Follow the [official RHDH plugin development guide](https://docs.redhat.com/en/documentation/red_hat_developer_hub/1.9/html/develop_and_deploy_dynamic_plugins_in_red_hat_developer_hub/develop-a-new-plugin_develop-and-deploy-plugins-in-rhdh) step by step:

| Task | What it does |
|------|--------------|
| **(Docs) Create Backstage App** | Runs `npx @backstage/create-app@0.7.6` to scaffold a full Backstage monorepo at `/projects/backstage-app` |
| **(Docs) Create plugin with yarn new** | Runs `yarn new` inside the Backstage app to scaffold a new plugin |

**Steps:**

1. Run **(Docs) Create Backstage App** — scaffolds `/projects/backstage-app`
2. Run **(Docs) Create plugin with yarn new** — select plugin type and enter an ID
3. Implement your plugin following the docs (sections 3.4–3.6)
4. Test locally with `cd /projects/backstage-app && yarn start` or against the real RHDH instance

## Plugin Details

| Field | Value |
|-------|-------|
| **Name** | ${{ values.pluginName }} |
| **Type** | ${{ values.pluginType }} |
| **Owner** | ${{ values.owner }} |

## Testing with the Dev Harness

The `dev/index.tsx` file includes a mock entity page for testing the `ExampleCard` component:

```bash
yarn start    # Starts on port 3000
```

Navigate to `http://localhost:3000/${{ values.pluginName }}/entity` to see the ExampleCard rendered with a mock entity.

## Commands

```bash
yarn install          # Install dependencies
yarn start            # Start development server (port 3000)
yarn test             # Run tests
yarn build            # Build for production
yarn lint             # Lint source code
yarn export-dynamic   # Export as RHDH dynamic plugin
```

## Exporting as a Dynamic Plugin

To manually export outside of Dev Spaces:

```bash
yarn add -D @red-hat-developer-hub/cli
npx @red-hat-developer-hub/cli plugin export --clean
```

The exported plugin will be in `dist-dynamic/`.
