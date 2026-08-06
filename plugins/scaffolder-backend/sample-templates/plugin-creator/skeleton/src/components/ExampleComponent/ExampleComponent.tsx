import React from 'react';
import { Typography, Grid } from '@material-ui/core';
import {
  InfoCard,
  Header,
  Page,
  Content,
  ContentHeader,
  HeaderLabel,
  SupportButton,
} from '@backstage/core-components';

const ExampleComponent = () => (
  <Page themeId="tool">
    <Header
      title="Welcome to ${{ values.pluginName }}!"
      subtitle="RHDH dynamic plugin"
    >
      <HeaderLabel label="Owner" value="${{ values.owner }}" />
      <HeaderLabel label="Lifecycle" value="Alpha" />
    </Header>
    <Content>
      <ContentHeader title="${{ values.pluginName }}">
        <SupportButton>
          This plugin was scaffolded by the Plugin Creator template.
        </SupportButton>
      </ContentHeader>
      <Grid container spacing={3} direction="column">
        <Grid item>
          <InfoCard title="Getting Started">
            <Typography variant="body1">
              Edit <code>src/components/ExampleComponent/ExampleComponent.tsx</code> to
              start building your plugin.
            </Typography>
          </InfoCard>
        </Grid>
      </Grid>
    </Content>
  </Page>
);

export default ExampleComponent;
