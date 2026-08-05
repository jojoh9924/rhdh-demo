# Customizing the Dev Spaces Devfile for Your Enterprise

This guide explains how to fork `rhdh-local` and configure the devfile to match your enterprise RHDH deployment.

## Quick Start

```bash
# 1. Fork the repo
gh repo fork redhat-developer/rhdh-local --org your-org --clone

# 2. Edit the devfile
cd rhdh-local
# Make changes per the configuration table below

# 3. Push your fork
git add devfile.yaml
git commit -m "chore: configure devfile for our RHDH instance"
git push origin main
```

## What to Change

All configuration points are marked with `CHANGEME` in `devfile.yaml`. Here's the full list:

| Line                                        | Variable / Field                                         | What to set                                                                | Example |
| ------------------------------------------- | -------------------------------------------------------- | -------------------------------------------------------------------------- | ------- |
| `components[tools].env.CLUSTER_APPS_DOMAIN` | Your OpenShift cluster's apps domain                     | `apps.ocp.mycompany.com`                                                   |
| `components[rhdh].image`                    | The RHDH image version matching your production instance | `quay.io/rhdh-community/rhdh:1.11`                                         |
| `components[rhdh].env.CLUSTER_APPS_DOMAIN`  | Same as tools container — must match                     | `apps.ocp.mycompany.com`                                                   |
| `components[rhdh].env.CATALOG_INDEX_IMAGE`  | Catalog index matching your RHDH version                 | `quay.io/rhdh/plugin-catalog-index:1.11`                                   |
| `components[sonataflow].image`              | Your SonataFlow version (or remove the entire component) | `registry.redhat.io/openshift-serverless-1/logic-swf-devmode-rhel9:1.37.2` |

### Optional: Proxy Configuration

If your developers are behind a corporate proxy, set these in both `tools` and `sonataflow` containers:

```yaml
- name: PROXY_HOST
  value: 'proxy.mycompany.com'
- name: PROXY_PORT
  value: '8080'
```

### Optional: Remove SonataFlow

If your RHDH instance doesn't use the Orchestrator plugin, remove the entire `sonataflow` component, its volumes (`sonataflow-m2-cache`, `sonataflow-workflows`), and its commands (`start-sonataflow`, `restart-sonataflow`) to reduce workspace resource consumption.

## Enterprise app-config

The `start-rhdh.sh` script configures RHDH at startup. To customize what plugins are loaded, catalog sources, auth providers, etc., modify:

- `config/app-config.yaml` — base RHDH configuration
- `config/dynamic-plugins.yaml` — which dynamic plugins to enable/disable
- `scripts/start-rhdh.sh` — startup orchestration

These files in your fork are what make the Dev Spaces RHDH instance match your production deployment.

## How Developers Use It

### Option A: Open rhdh-local directly (generic plugin development)

Developers open your fork in Dev Spaces to get a complete RHDH environment, then clone their plugin repo inside:

```
https://devspaces.mycompany.com/#https://github.com/your-org/rhdh-local
```

Inside the workspace:

```bash
cd /projects
git clone https://github.com/your-org/my-plugin.git
# Then use "Deploy plugin to RHDH" task
```

### Option B: Plugin Creator template (recommended)

The Plugin Creator software template stamps out a plugin-specific devfile into each new plugin repo. That devfile references your `rhdh-local` fork as a cloned project:

```yaml
projects:
  - name: rhdh-local
    git:
      remotes:
        origin: https://github.com/your-org/rhdh-local.git
```

The developer opens their plugin repo in Dev Spaces and gets both their code and your enterprise RHDH configuration.

## Version Alignment

Keep your fork's devfile in sync with your RHDH upgrades:

| When you upgrade... | Update in devfile                                  |
| ------------------- | -------------------------------------------------- |
| RHDH version        | `components[rhdh].image` and `CATALOG_INDEX_IMAGE` |
| SonataFlow version  | `components[sonataflow].image`                     |
| OpenShift cluster   | `CLUSTER_APPS_DOMAIN` in both containers           |

## Resource Requirements

The full workspace (all 3 containers) requires:

| Resource | Minimum                   | Recommended |
| -------- | ------------------------- | ----------- |
| Memory   | 8Gi                       | 12Gi        |
| CPU      | 4 cores                   | 6 cores     |
| Storage  | 28Gi (sum of all volumes) | 28Gi        |

Ensure your Dev Spaces instance has quotas configured to allow this. Without SonataFlow, requirements drop to ~6Gi memory / 3 cores.

## Troubleshooting

**Can't see plugin files in the file explorer sidebar**

The IDE opens with the file explorer rooted at the first cloned project (e.g., `/projects/rhdh-local`). Plugins you create at `/projects/<plugin-name>` are siblings, not children. Fix by:

- **File → Open Folder → `/projects`** — reopens the workspace showing everything
- Or **File → Add Folder to Workspace** → pick your plugin directory

**`EADDRINUSE: address already in use :::7007` on restart**

The `rhdh` container is minimal (no `ps`, `ss`, `pkill`). The Restart RHDH task uses `kill -9 -1` to force-kill all user processes. If you get port conflicts:

- Make sure you're using the **Restart RHDH** devfile task (runs in the `rhdh` container automatically)
- Don't start RHDH manually from a second terminal — there's likely already an instance running from the `postStart` event
- Check your terminal tabs: the "Start RHDH" task terminal already has a running instance

**CORS errors / `baseUrl: http://localhost:7007` in browser console**

The `CLUSTER_APPS_DOMAIN` env var must match your actual cluster. If left empty, the start script attempts auto-detection from `DEVWORKSPACE_ROUTING_*` variables. If auto-detection fails:

1. Find your domain: check the RHDH endpoint URL in the Dev Spaces dashboard
2. Set it in both the `tools` and `rhdh` container env vars in the devfile
3. Or export it before starting: `export CLUSTER_APPS_DOMAIN=apps.your-cluster.example.com`

**Debugging — use the `tools` container**

The `rhdh` container is a minimal UBI image. It intentionally lacks `ps`, `ss`, `top`, `curl`, and other diagnostic tools. Always open a terminal in the **tools** container for debugging. Both containers share the `/projects` and `/dynamic-plugins-root` volumes, so you can inspect files from either.

**Workspace fails to start (image pull error)**

- Verify image references are accessible from your cluster
- `registry.redhat.io` images require a pull secret — ensure it's configured in your Dev Spaces namespace

**RHDH doesn't start (port 7007 never opens)**

- Check the "Start RHDH" task terminal for errors
- Look for `[devspaces-start]` log lines showing what went wrong
- Verify `scripts/start-rhdh.sh` is executable and the script logic matches your RHDH version

**Plugin doesn't appear after deploy**

- The **Deploy plugin to RHDH** task now auto-copies the built plugin to `/dynamic-plugins-root/` and auto-registers it in `dynamic-plugins.override.yaml`
- After deploying, you must run **Restart RHDH** to load the new plugin
- Check RHDH startup logs for your plugin name (loaded vs error)
- For frontend plugins, navigate to `/<plugin-id>` in the browser
- Check the browser console (F12) for JavaScript errors loading the plugin bundle

**SonataFlow Maven downloads are slow**

- The `sonataflow-m2-cache` volume persists across workspace restarts
- First start will be slow (~5-10 min for Maven downloads); subsequent starts reuse the cache
