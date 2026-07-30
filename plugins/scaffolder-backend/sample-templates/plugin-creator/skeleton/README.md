# ${{ values.pluginName }}

A Backstage ${{ values.pluginType }} plugin.

## Getting Started

This plugin was scaffolded using the Plugin Creator template. To start developing:

1. Open this repo in OpenShift Dev Spaces (dependencies are pre-configured via `devfile.yaml`)
2. Run `yarn install` to install dependencies
3. Run `yarn start` to launch the dev server on port 3000

## Plugin Details

| Field | Value |
|-------|-------|
| **Name** | ${{ values.pluginName }} |
| **Type** | ${{ values.pluginType }} |
| **Owner** | ${{ values.owner }} |

## Development

```bash
# Install dependencies
yarn install

# Start development server
yarn start

# Run tests
yarn test

# Build for production
yarn build
```
