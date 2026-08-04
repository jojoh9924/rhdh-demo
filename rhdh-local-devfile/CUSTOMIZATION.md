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

**Workspace fails to start (image pull error)**

- Verify image references are accessible from your cluster
- `registry.redhat.io` images require a pull secret — ensure it's configured in your Dev Spaces namespace

**RHDH doesn't start (port 7007 never opens)**

- Check `/tmp/rhdh-start.log` in the rhdh container
- Verify `scripts/start-rhdh.sh` is executable and the script logic matches your RHDH version

**Plugin doesn't appear after deploy**

- Confirm the plugin was exported to `/dynamic-plugins-root`
- Check RHDH logs for plugin loading errors: look for your plugin name in the startup output
- Ensure `WAIT_FOR_PLUGINS_TIMEOUT` is long enough (default: 180s)

**SonataFlow Maven downloads are slow**

- The `sonataflow-m2-cache` volume persists across workspace restarts
- First start will be slow (~5-10 min for Maven downloads); subsequent starts reuse the cache
