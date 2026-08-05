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
