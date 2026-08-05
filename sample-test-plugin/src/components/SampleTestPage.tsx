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
