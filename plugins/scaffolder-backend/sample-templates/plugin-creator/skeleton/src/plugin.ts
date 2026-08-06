import {
  createPlugin,
  createRouteRef,
  createRoutableExtension,
  createComponentExtension,
} from '@backstage/core-plugin-api';

const rootRouteRef = createRouteRef({
  id: '${{ values.pluginName }}',
});

export const plugin = createPlugin({
  id: '${{ values.pluginName }}',
  routes: {
    root: rootRouteRef,
  },
});

export const ${{ values.pluginName | replace('-', '') | capitalize }}Page = plugin.provide(
  createRoutableExtension({
    name: '${{ values.pluginName | replace('-', '') | capitalize }}Page',
    component: () =>
      import('./components/ExampleComponent').then(m => m.default),
    mountPoint: rootRouteRef,
  }),
);

export const ExampleCard = plugin.provide(
  createComponentExtension({
    name: 'ExampleCard',
    component: {
      lazy: () =>
        import('./components/ExampleCard').then(m => m.ExampleCard),
    },
  }),
);
