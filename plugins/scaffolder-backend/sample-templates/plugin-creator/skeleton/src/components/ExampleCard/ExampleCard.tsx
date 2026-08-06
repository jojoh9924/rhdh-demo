import React from 'react';
import { InfoCard } from '@backstage/core-components';
import { useEntity } from '@backstage/plugin-catalog-react';

export const ExampleCard = () => {
  const { entity } = useEntity();
  return (
    <InfoCard title="${{ values.pluginName }}">
      <p>Entity: {entity.metadata.name}</p>
    </InfoCard>
  );
};
