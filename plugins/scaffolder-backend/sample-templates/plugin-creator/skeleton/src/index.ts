export {
  plugin as ${{ values.pluginName | replace('-', '') }}Plugin,
  ${{ values.pluginName | replace('-', '') | capitalize }}Page,
  ExampleCard,
} from './plugin';
