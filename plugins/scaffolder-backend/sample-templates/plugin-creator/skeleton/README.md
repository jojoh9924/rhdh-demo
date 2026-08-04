# ${{ values.pluginName }}

A Backstage ${{ values.pluginType }} plugin for Red Hat Developer Hub.

## Getting Started

This plugin was scaffolded using the Plugin Creator template. The repository includes a `devfile.yaml` that provisions a complete development environment in OpenShift Dev Spaces with:

- **tools container** — Node.js, TypeScript, Yarn for plugin development
- **rhdh container** — a real RHDH 1.10 instance for integration testing

### Open in Dev Spaces

Click **"Open in Dev Spaces"** from the RHDH catalog, or navigate directly to:

```
https://workspaces.openshift.com/#https://github.com/${{ values.destination.owner }}/${{ values.destination.repo }}
```

When the workspace starts, dependencies are installed and RHDH boots automatically.

## Development Workflow

Use the IDE task menu (Terminal → Run Task) for the numbered workflow:

| Task | What it does |
|------|--------------|
| **1. Install dependencies** | `yarn install` (runs automatically on workspace start) |
| **2. Start plugin dev server** | Hot-reloading dev server on port 3000 for isolated plugin development |
| **3. Run tests** | Executes the plugin test suite |
| **4. Start RHDH** | Boots the RHDH instance on port 7007 (runs automatically on workspace start) |
| **5. Deploy plugin to RHDH** | Exports the plugin as a dynamic plugin into the RHDH plugins volume |
| **6. Restart RHDH** | Reloads RHDH to pick up the deployed plugin |
| **7. Push branch & create PR** | Commits, pushes, and opens a pull request via `gh` CLI |

### Typical loop

1. Write plugin code in `src/`
2. Use task **2** for fast feedback with hot-reload
3. When ready to test in RHDH, run task **5** then **6**
4. Verify your plugin at the RHDH endpoint (port 7007)
5. Ship with task **7**

## Plugin Details

| Field | Value |
|-------|-------|
| **Name** | ${{ values.pluginName }} |
| **Type** | ${{ values.pluginType }} |
| **Owner** | ${{ values.owner }} |

## Commands

```bash
yarn install    # Install dependencies
yarn start      # Start development server (port 3000)
yarn test       # Run tests
yarn build      # Build for production
yarn lint       # Lint source code
```

## Exporting as a Dynamic Plugin

To manually export outside of Dev Spaces:

```bash
yarn add -D @red-hat-developer-hub/cli
npx @red-hat-developer-hub/cli plugin export --clean
```

The exported plugin will be in `dist-dynamic/`.
