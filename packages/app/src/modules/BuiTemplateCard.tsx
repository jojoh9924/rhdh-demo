/*
 * Copyright 2026 The Backstage Authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { useCallback, useMemo, useState } from 'react';
import {
  ANNOTATION_SOURCE_LOCATION,
  RELATION_OWNED_BY,
} from '@backstage/catalog-model';
import { useAnalytics } from '@backstage/frontend-plugin-api';
import {
  EntityRefLink,
  getEntityRelations,
} from '@backstage/plugin-catalog-react';
import {
  Box,
  Button,
  Card,
  CardFooter,
  CardHeader,
  Flex,
  Tag,
  TagGroup,
  Text,
  Tooltip,
  TooltipTrigger,
} from '@backstage/ui';
import type { TemplateCardComponentProps } from '@backstage/plugin-scaffolder-react/alpha';
import styles from './BuiTemplateCard.module.css';

const MAX_TAGS = 4;
const TIME_SAVED_ANNOTATION = 'rhdh.redhat.com/time-saved';

const DEFAULT_TIME_SAVED: Record<string, string> = {
  service: '8 hours',
  website: '4 hours',
  library: '3 hours',
  documentation: '2 hours',
};
const FALLBACK_TIME_SAVED = 'unknown';
const TIME_SAVED_SNIPPET = `rhdh.redhat.com/time-saved: '<duration>'`;

function ClockIcon() {
  return (
    <svg
      width="12"
      height="12"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
    >
      <circle cx="12" cy="12" r="10" />
      <polyline points="12 6 12 12 16 14" />
    </svg>
  );
}

function TimeSavedTooltipContent() {
  const [copied, setCopied] = useState(false);

  const handleCopy = useCallback(() => {
    window.navigator.clipboard.writeText(TIME_SAVED_SNIPPET).then(() => {
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    });
  }, []);

  return (
    <div className={styles.tooltipContent}>
      <Text variant="body-x-small" color="primary">
        Help others see the value of this template. Add this annotation to its
        template.yaml:
      </Text>
      <div className={styles.tooltipSnippet}>
        <code className={styles.tooltipCode}>{TIME_SAVED_SNIPPET}</code>
        {/* eslint-disable-next-line react/forbid-elements */}
        <button
          type="button"
          className={styles.tooltipCopyButton}
          onClick={handleCopy}
          aria-label="Copy annotation to clipboard"
        >
          {copied ? '✓' : '⎘'}
        </button>
      </div>
    </div>
  );
}

export function BuiTemplateCard(props: TemplateCardComponentProps) {
  const { template, onSelected } = props;
  const analytics = useAnalytics();

  const {
    spec: { type },
    metadata: { tags, description, name, title, annotations },
  } = template;

  const hasExplicitTimeSaved = !!annotations?.[TIME_SAVED_ANNOTATION];
  const timeSaved =
    annotations?.[TIME_SAVED_ANNOTATION] ??
    DEFAULT_TIME_SAVED[type] ??
    FALLBACK_TIME_SAVED;

  const sourceLocation =
    annotations?.[ANNOTATION_SOURCE_LOCATION] ??
    annotations?.['backstage.io/managed-by-location'] ??
    undefined;

  const visibleTags = useMemo(
    () =>
      Array.from(new Set([type, ...(tags ?? [])].filter(Boolean))).slice(
        0,
        MAX_TAGS,
      ),
    [type, tags],
  );

  const owner = getEntityRelations(template, RELATION_OWNED_BY)[0];

  const handleRun = () => {
    analytics.captureEvent('click', 'Template has been opened');
    onSelected?.();
  };

  return (
    <Card className={styles.templateCard}>
      <CardHeader>
        <Text
          as="h3"
          variant="body-medium"
          weight="bold"
          color="primary"
          className={styles.templateName}
        >
          {title ?? name}
        </Text>
      </CardHeader>
      <Box px="3" className={styles.templateBody}>
        {description && (
          <Text
            as="p"
            variant="body-small"
            color="secondary"
            className={styles.templateDescription}
          >
            {description}
          </Text>
        )}
        <TagGroup>
          {hasExplicitTimeSaved ? (
            <TooltipTrigger delay={300}>
              <Tag id="time-saved">
                <ClockIcon />
                Est. time saved: {timeSaved}
              </Tag>
              <Tooltip>
                <Text variant="body-x-small" color="primary">
                  This number reflects the typical time to do this work without
                  the template, as reported by the owner.
                </Text>
              </Tooltip>
            </TooltipTrigger>
          ) : (
            <TooltipTrigger delay={300}>
              <Tag
                id="time-saved"
                href={sourceLocation?.replace(/^(url|file):/, '') ?? '#'}
                className={styles.addTimeSavedTag}
              >
                <ClockIcon />
                Add est. time saved
              </Tag>
              <Tooltip>
                <TimeSavedTooltipContent />
              </Tooltip>
            </TooltipTrigger>
          )}
          {visibleTags.map(t => (
            <Tag key={t}>{t!}</Tag>
          ))}
        </TagGroup>
      </Box>
      <CardFooter>
        <Flex justify="between" align="end">
          <Button size="small" variant="secondary" onPress={handleRun}>
            Run
          </Button>
          {owner && (
            <Flex gap="0" direction="column" align="end">
              <Text variant="body-x-small" color="secondary">
                Created by
              </Text>
              <Text variant="body-x-small" color="primary">
                <EntityRefLink entityRef={owner} hideIcon />
              </Text>
            </Flex>
          )}
        </Flex>
      </CardFooter>
    </Card>
  );
}
