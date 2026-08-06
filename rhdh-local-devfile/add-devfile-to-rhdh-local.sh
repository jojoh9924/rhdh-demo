#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# add-devfile-to-rhdh-local.sh
#
# Script to add the enterprise-configurable devfile.yaml to an rhdh-local repo.
# Run this from inside your rhdh-local clone/fork.
#
# Usage:
#   cd /path/to/your/rhdh-local-fork
#   bash /path/to/add-devfile-to-rhdh-local.sh
#
# Or with customization:
#   CLUSTER_DOMAIN=apps.ocp.mycompany.com \
#   RHDH_VERSION=1.11 \
#   bash /path/to/add-devfile-to-rhdh-local.sh
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

# ── Configuration (override via environment variables) ──
CLUSTER_DOMAIN="${CLUSTER_DOMAIN:-apps.example.com}"
RHDH_VERSION="${RHDH_VERSION:-1.10}"
SONATAFLOW_IMAGE="${SONATAFLOW_IMAGE:-registry.redhat.io/openshift-serverless-1/logic-swf-devmode-rhel9:1.37.2}"
INCLUDE_SONATAFLOW="${INCLUDE_SONATAFLOW:-true}"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Adding devfile.yaml to rhdh-local                          ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  Cluster domain:  ${CLUSTER_DOMAIN}"
echo "║  RHDH version:    ${RHDH_VERSION}"
echo "║  SonataFlow:      ${INCLUDE_SONATAFLOW}"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Verify we're in a git repo
if [ ! -d .git ]; then
  echo "ERROR: Not in a git repository. Run this from your rhdh-local fork root."
  exit 1
fi

# Check for existing devfile
if [ -f devfile.yaml ]; then
  echo "WARNING: devfile.yaml already exists."
  read -r -p "Overwrite? [y/N] " response
  case "$response" in
    [yY]) echo "Overwriting..." ;;
    *) echo "Aborted."; exit 0 ;;
  esac
fi

# ── Generate devfile.yaml ──
echo "[1/3] Generating devfile.yaml..."

cat > devfile.yaml << 'DEVFILE_START'
schemaVersion: 2.3.0
metadata:
  name: rhdh-plugin-dev
  version: 1.0.0
  displayName: RHDH Plugin Development
  description: >-
    Dev Spaces workspace for developing and testing dynamic plugins against a
    local RHDH instance. Fork this repo and customize the CHANGEME values
    below to match your enterprise RHDH deployment.
attributes:
  controller.devfile.io/storage-type: per-workspace
components:
  - name: tools
    container:
      image: quay.io/devfile/universal-developer-image:ubi9-latest
      mountSources: true
      memoryLimit: 6Gi
      memoryRequest: 512Mi
      cpuLimit: "2"
      cpuRequest: 500m
      env:
        - name: CLUSTER_APPS_DOMAIN
DEVFILE_START

# Inject cluster domain (can't use heredoc for variable interpolation in middle)
cat >> devfile.yaml << EOF
          value: "${CLUSTER_DOMAIN}"
EOF

cat >> devfile.yaml << 'DEVFILE_TOOLS_REST'
        - name: PLUGIN_NAME
          value: ""
        - name: DYNAMIC_PLUGINS_ROOT
          value: /dynamic-plugins-root
        - name: NODE_OPTIONS
          value: "--max-old-space-size=3072"
        - name: PROXY_HOST
          value: ""
        - name: PROXY_PORT
          value: ""
      endpoints:
        - name: plugin-dev
          exposure: public
          targetPort: 3000
          protocol: https
          attributes:
            discoverable: true
            urlRewriteSupported: false
      volumeMounts:
        - name: dynamic-plugins-root
          path: /dynamic-plugins-root
        - name: yarn-cache
          path: /home/user/.cache/yarn
  - name: rhdh
    container:
DEVFILE_TOOLS_REST

cat >> devfile.yaml << EOF
      image: quay.io/rhdh-community/rhdh:${RHDH_VERSION}
EOF

cat >> devfile.yaml << 'DEVFILE_RHDH'
      command: ["tail"]
      args: ["-f", "/dev/null"]
      mountSources: true
      memoryLimit: 6Gi
      memoryRequest: 1Gi
      cpuLimit: "2"
      cpuRequest: 500m
      env:
        - name: DEVSPACE_SCRIPTS_DIR
          value: /projects/rhdh-local
        - name: BASE_URL
          value: auto
        - name: RHDH_PUBLIC_ENDPOINT_NAME
          value: rhdh
DEVFILE_RHDH

cat >> devfile.yaml << EOF
        - name: CLUSTER_APPS_DOMAIN
          value: "${CLUSTER_DOMAIN}"
EOF

cat >> devfile.yaml << 'DEVFILE_RHDH_ENV'
        - name: NODE_ENV
          value: development
        - name: NODE_OPTIONS
          value: "--inspect=0.0.0.0:9229 --no-node-snapshot"
DEVFILE_RHDH_ENV

cat >> devfile.yaml << EOF
        - name: CATALOG_INDEX_IMAGE
          value: quay.io/rhdh/plugin-catalog-index:${RHDH_VERSION}
EOF

cat >> devfile.yaml << 'DEVFILE_RHDH_REST'
        - name: WAIT_FOR_PLUGINS_TIMEOUT
          value: "180"
        - name: CATALOG_ENTITIES_EXTRACT_DIR
          value: /opt/app-root/src/extensions
        - name: ENABLE_AUTH_PROVIDER_MODULE_OVERRIDE
          value: "true"
        - name: ENABLE_CORE_ROOTHTTPROUTER_OVERRIDE
          value: "true"
      endpoints:
        - name: rhdh
          exposure: public
          targetPort: 7007
          protocol: https
          attributes:
            discoverable: true
            urlRewriteSupported: false
        - name: node-debug
          exposure: internal
          targetPort: 9229
          protocol: tcp
      volumeMounts:
        - name: dynamic-plugins-root
          path: /opt/app-root/src/dynamic-plugins-root
        - name: dynamic-plugins-root
          path: /dynamic-plugins-root
        - name: extensions-catalog
          path: /opt/app-root/src/extensions
        - name: rhdh-generated
          path: /opt/app-root/src/generated
DEVFILE_RHDH_REST

# Conditionally add SonataFlow
if [ "$INCLUDE_SONATAFLOW" = "true" ]; then
cat >> devfile.yaml << EOF
  - name: sonataflow
    container:
      image: ${SONATAFLOW_IMAGE}
      command: ["tail"]
      args: ["-f", "/dev/null"]
      mountSources: true
      memoryLimit: 4Gi
      memoryRequest: 1Gi
      cpuLimit: "2"
      cpuRequest: 500m
      env:
        - name: WORKFLOW_REPO_DIR
          value: /projects/rhdh-local
        - name: DEVSPACE_SCRIPTS_DIR
          value: /projects/rhdh-local
        - name: PROXY_HOST
          value: ""
        - name: PROXY_PORT
          value: ""
        - name: NON_PROXY_HOSTS
          value: ""
        - name: QUARKUS_HTTP_PORT
          value: "8899"
        - name: KOGITO_SERVICE_URL
          value: http://localhost:8899
        - name: KOGITO.CODEGEN.PROCESS.FAILONERROR
          value: "false"
        - name: MAX_YAML_CODE_POINTS
          value: "35000000"
        - name: MAX_ENTRY_SIZE
          value: "30000000"
        - name: MAVEN_ARGS_APPEND
          value: >-
            -s /home/kogito/.m2/settings.xml
            -DmaxYamlCodePoints=\${MAX_YAML_CODE_POINTS}
            -T1C
            -Dmaven.artifact.threads=8
            -Djava.net.useSystemProxies=false
        - name: QUARKUS_EXTENSIONS
          value: >-
            io.quarkiverse.openapi.generator:quarkus-openapi-generator:2.12.0,
            org.kie:kie-addons-quarkus-monitoring-sonataflow,
            io.quarkus:quarkus-resteasy-client-oidc-filter,
            org.kie:kogito-addons-quarkus-jobs-knative-eventing
        - name: BACKSTAGE_NOTIFICATIONS_URL
          value: http://localhost:7007
        - name: QUARKUS_PROFILE
          value: "local-dev"
      endpoints:
        - name: sonataflow
          exposure: public
          targetPort: 8899
          protocol: https
          attributes:
            discoverable: true
            urlRewriteSupported: false
      volumeMounts:
        - name: sonataflow-m2-cache
          path: /home/kogito/.m2/repository
        - name: sonataflow-workflows
          path: /home/kogito/serverless-workflow-project/src/main/resources
EOF
fi

cat >> devfile.yaml << 'DEVFILE_VOLUMES'
  # ── Volumes ──
  - name: dynamic-plugins-root
    volume:
      size: 2Gi
  - name: extensions-catalog
    volume:
      size: 1Gi
  - name: rhdh-generated
    volume:
      size: 512Mi
  - name: yarn-cache
    volume:
      size: 2Gi
DEVFILE_VOLUMES

if [ "$INCLUDE_SONATAFLOW" = "true" ]; then
cat >> devfile.yaml << 'DEVFILE_SF_VOLUMES'
  - name: sonataflow-m2-cache
    volume:
      size: 2Gi
  - name: sonataflow-workflows
    volume:
      size: 256Mi
DEVFILE_SF_VOLUMES
fi

cat >> devfile.yaml << 'DEVFILE_VOLUMES_END'
  - name: projects
    volume:
      size: 20Gi
DEVFILE_VOLUMES_END

cat >> devfile.yaml << 'DEVFILE_COMMANDS'
commands:
  - id: start-rhdh
    exec:
      label: "Start RHDH"
      component: rhdh
      commandLine: |
        chmod +x "/projects/rhdh-local/scripts/start-rhdh.sh" 2>/dev/null
        /projects/rhdh-local/scripts/start-rhdh.sh
      workingDir: /projects/rhdh-local
      group:
        kind: run
        isDefault: true
  - id: restart-rhdh
    exec:
      label: "Restart RHDH"
      component: rhdh
      commandLine: |
        echo "[rhdh] Stopping RHDH..."
        pkill -f 'node.*packages/backend' 2>/dev/null || true
        sleep 2
        pkill -9 -f 'node.*packages/backend' 2>/dev/null || true
        sleep 1
        echo "[rhdh] Starting RHDH..."
        chmod +x "/projects/rhdh-local/scripts/start-rhdh.sh" 2>/dev/null
        /projects/rhdh-local/scripts/start-rhdh.sh
      workingDir: /projects/rhdh-local
      group:
        kind: run
        isDefault: false
  - id: deploy-plugin
    exec:
      label: "Deploy plugin to RHDH"
      component: tools
      commandLine: |
        set -e
        _PLUGIN="${PLUGIN_NAME:-}"
        if [ -z "$_PLUGIN" ] && [ -t 0 ]; then
          read -r -p "[plugin] Enter plugin directory name: " _PLUGIN
        fi
        [ -z "$_PLUGIN" ] && { echo "[plugin] ERROR: Set PLUGIN_NAME or provide input"; exit 1; }
        _PLUGIN_DIR="/projects/$_PLUGIN"
        [ -d "$_PLUGIN_DIR" ] || { echo "[plugin] ERROR: Directory $_PLUGIN_DIR not found"; exit 1; }
        cd "$_PLUGIN_DIR"
        [ -f package.json ] || { echo "[plugin] ERROR: No package.json in $_PLUGIN_DIR"; exit 1; }
        # Anchor yarn to this directory so it doesn't traverse up to a parent project root
        [ -f yarn.lock ] || touch yarn.lock
        echo "[plugin] Installing dependencies..."
        yarn install
        echo "[plugin] Exporting dynamic plugin..."
        rm -rf dist-dynamic
        npx --yes @red-hat-developer-hub/cli@latest plugin export
        echo ""
        echo "[plugin] Done. Run 'Restart RHDH' to load the updated plugin."
      workingDir: /projects
      group:
        kind: build
        isDefault: false
DEVFILE_COMMANDS

if [ "$INCLUDE_SONATAFLOW" = "true" ]; then
cat >> devfile.yaml << 'DEVFILE_SF_COMMANDS'
  - id: start-sonataflow
    exec:
      label: "Start SonataFlow"
      component: sonataflow
      commandLine: |
        chmod +x "/projects/rhdh-local/scripts/start-orchestrator.sh" 2>/dev/null
        /projects/rhdh-local/scripts/start-orchestrator.sh
      workingDir: /home/kogito/serverless-workflow-project
      group:
        kind: run
        isDefault: false
  - id: restart-sonataflow
    exec:
      label: "Restart SonataFlow"
      component: sonataflow
      commandLine: |
        echo "[sonataflow] Stopping..."
        pkill -f 'java.*quarkus' 2>/dev/null || true
        sleep 3
        pkill -9 -f 'java.*quarkus' 2>/dev/null || true
        sleep 1
        echo "[sonataflow] Starting..."
        chmod +x "/projects/rhdh-local/scripts/start-orchestrator.sh" 2>/dev/null
        /projects/rhdh-local/scripts/start-orchestrator.sh
      workingDir: /home/kogito/serverless-workflow-project
      group:
        kind: run
        isDefault: false
DEVFILE_SF_COMMANDS
fi

cat >> devfile.yaml << 'DEVFILE_EVENTS'
events:
  postStart:
    - start-rhdh
DEVFILE_EVENTS

echo "[2/3] Copying CUSTOMIZATION.md..."

# Check if CUSTOMIZATION.md source exists alongside this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/CUSTOMIZATION.md" ]; then
  cp "$SCRIPT_DIR/CUSTOMIZATION.md" ./CUSTOMIZATION.md
  echo "  Copied CUSTOMIZATION.md"
else
  echo "  CUSTOMIZATION.md not found alongside script — skipping (add manually)"
fi

echo "[3/3] Done!"
echo ""
echo "Generated files:"
echo "  - devfile.yaml ($(wc -l < devfile.yaml) lines)"
[ -f CUSTOMIZATION.md ] && echo "  - CUSTOMIZATION.md"
echo ""
echo "Next steps:"
echo "  1. Review devfile.yaml and verify the CHANGEME values"
echo "  2. Ensure scripts/start-rhdh.sh exists and is executable"
echo "  3. Commit and push:"
echo "     git add devfile.yaml CUSTOMIZATION.md"
echo "     git commit -m 'feat: add Dev Spaces devfile for plugin development'"
echo "     git push origin main"
echo ""
echo "  4. Developers can now open this repo in Dev Spaces:"
echo "     https://<your-devspaces-url>/#https://github.com/<your-org>/rhdh-local"
