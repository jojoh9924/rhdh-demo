#!/bin/bash
set -e

PLUGIN_DIR="/projects/sample-test-plugin"

if [ -d "$PLUGIN_DIR" ]; then
  echo "[plugin] sample-test-plugin already exists at $PLUGIN_DIR"
  echo "[plugin] To rebuild, remove it first: rm -rf $PLUGIN_DIR"
  exit 0
fi

echo "[plugin] Creating sample-test-plugin at $PLUGIN_DIR..."
mkdir -p "$PLUGIN_DIR/src/components"

# ── package.json ──
cat > "$PLUGIN_DIR/package.json" << 'EOF'
{
  "name": "@internal/plugin-sample-test",
  "version": "0.1.0",
  "backstage": {
    "role": "frontend-plugin",
    "pluginId": "sample-test",
    "pluginPackages": ["@internal/plugin-sample-test"]
  },
  "publishConfig": {
    "access": "public",
    "main": "dist/index.esm.js",
    "types": "dist/index.d.ts"
  },
  "private": true,
  "license": "Apache-2.0",
  "sideEffects": false,
  "main": "src/index.ts",
  "types": "src/index.ts",
  "files": ["dist"],
  "scripts": {
    "build": "backstage-cli package build",
    "clean": "backstage-cli package clean",
    "start": "backstage-cli package start"
  },
  "dependencies": {
    "@backstage/core-components": "^0.16.3",
    "@backstage/core-plugin-api": "^1.10.3",
    "@backstage/theme": "^0.6.6",
    "@material-ui/core": "^4.12.2"
  },
  "devDependencies": {
    "@backstage/cli": "^0.30.4",
    "@types/react": "^18.0.0",
    "react": "^18.0.2",
    "react-dom": "^18.0.2",
    "react-router-dom": "^6.30.2",
    "typescript": "~5.4.0"
  },
  "peerDependencies": {
    "react": "^17.0.0 || ^18.0.0",
    "react-dom": "^17.0.0 || ^18.0.0",
    "react-router-dom": "^6.30.2"
  }
}
EOF

# ── tsconfig.json ──
cat > "$PLUGIN_DIR/tsconfig.json" << 'EOF'
{
  "extends": "@backstage/cli/config/tsconfig.json",
  "include": ["src"],
  "exclude": ["node_modules"],
  "compilerOptions": {
    "outDir": "dist-types",
    "rootDir": "."
  }
}
EOF

# ── scalprum-config.json ──
cat > "$PLUGIN_DIR/scalprum-config.json" << 'EOF'
{
  "name": "internal.plugin-sample-test",
  "exposedModules": {
    "PluginRoot": "./src/index.ts"
  }
}
EOF

# ── src/index.ts ──
cat > "$PLUGIN_DIR/src/index.ts" << 'EOF'
export { sampleTestPlugin, SampleTestPage } from './plugin';
EOF

# ── src/routes.ts ──
cat > "$PLUGIN_DIR/src/routes.ts" << 'EOF'
import { createRouteRef } from '@backstage/core-plugin-api';

export const rootRouteRef = createRouteRef({
  id: 'sample-test',
});
EOF

# ── src/plugin.ts ──
cat > "$PLUGIN_DIR/src/plugin.ts" << 'EOF'
import {
  createPlugin,
  createRoutableExtension,
} from '@backstage/core-plugin-api';

import { rootRouteRef } from './routes';

export const sampleTestPlugin = createPlugin({
  id: 'sample-test',
  routes: {
    root: rootRouteRef,
  },
});

export const SampleTestPage = sampleTestPlugin.provide(
  createRoutableExtension({
    name: 'SampleTestPage',
    component: () =>
      import('./components/SampleTestPage').then(m => m.SampleTestPage),
    mountPoint: rootRouteRef,
  }),
);
EOF

# ── src/components/SampleTestPage.tsx ──
cat > "$PLUGIN_DIR/src/components/SampleTestPage.tsx" << 'EOF'
import React from 'react';
import {
  Header,
  Page,
  Content,
  InfoCard,
  StatusOK,
} from '@backstage/core-components';
import { Grid, Typography, makeStyles } from '@material-ui/core';

const useStyles = makeStyles(theme => ({
  container: {
    padding: theme.spacing(3),
  },
  statusRow: {
    display: 'flex',
    alignItems: 'center',
    gap: theme.spacing(1),
    marginTop: theme.spacing(2),
  },
}));

export const SampleTestPage = () => {
  const classes = useStyles();

  return (
    <Page themeId="tool">
      <Header title="Sample Test Plugin" subtitle="Dev Spaces workflow test" />
      <Content className={classes.container}>
        <Grid container spacing={3}>
          <Grid item xs={12} md={6}>
            <InfoCard title="Plugin Status">
              <Typography variant="body1">
                This plugin was successfully deployed to RHDH.
              </Typography>
              <div className={classes.statusRow}>
                <StatusOK />
                <Typography variant="body2">
                  Dynamic plugin loaded and running
                </Typography>
              </div>
            </InfoCard>
          </Grid>
          <Grid item xs={12} md={6}>
            <InfoCard title="Environment Info">
              <Typography variant="body2" component="div">
                <ul>
                  <li>Plugin ID: sample-test</li>
                  <li>Version: 0.1.0</li>
                  <li>Rendered at: {new Date().toLocaleString()}</li>
                </ul>
              </Typography>
            </InfoCard>
          </Grid>
        </Grid>
      </Content>
    </Page>
  );
};
EOF

echo ""
echo "[plugin] sample-test-plugin created successfully!"
echo ""
echo "[plugin] Next steps:"
echo "  1. export PLUGIN_NAME=sample-test-plugin"
echo "  2. Run the 'Deploy plugin to RHDH' task"
echo "  3. Run 'Restart RHDH'"
echo "  4. Navigate to /sample-test in the RHDH UI"
