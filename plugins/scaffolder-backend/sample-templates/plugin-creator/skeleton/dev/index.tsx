import React from 'react';
import { createDevApp } from '@backstage/dev-utils';
import { Entity } from '@backstage/catalog-model';
import { EntityProvider } from '@backstage/plugin-catalog-react';
import { Page, Header, Content } from '@backstage/core-components';
import { Grid } from '@material-ui/core';
import { plugin, ExampleCard } from '../src/plugin';

const mockEntity: Entity = {
  apiVersion: 'backstage.io/v1alpha1',
  kind: 'Component',
  metadata: {
    name: 'example-service',
    description: 'An example service component for plugin development.',
  },
  spec: {
    type: 'service',
    lifecycle: 'production',
    owner: 'team-platform',
  },
};

const entityPage = (
  <EntityProvider entity={mockEntity}>
    <Page themeId="service">
      <Header
        title={mockEntity.metadata.name}
        subtitle={`${mockEntity.kind} · ${(mockEntity.spec as any)?.type}`}
      />
      <Content>
        <Grid container spacing={3} alignItems="stretch">
          <Grid item md={6} xs={12}>
            <ExampleCard />
          </Grid>
        </Grid>
      </Content>
    </Page>
  </EntityProvider>
);

createDevApp()
  .registerPlugin(plugin)
  .addPage({
    element: entityPage,
    title: 'Entity Page',
    path: '/${{ values.pluginName }}/entity',
  })
  .render();
