import {
  createPlugin,
  createRoutableExtension,
} from '@backstage/core-plugin-api';

export const plugin = createPlugin({
  id: '${{ values.pluginName }}',
});

export const ${{ values.pluginName | replace('-', '') | capitalize }}Page = plugin.provide(
  createRoutableExtension({
    name: '${{ values.pluginName | replace('-', '') | capitalize }}Page',
    component: () => import('./components/ExampleComponent').then(m => m.default),
    mountPoint: rootRouteRef,
  }),
);
