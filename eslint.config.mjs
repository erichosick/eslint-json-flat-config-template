import jsonc from 'eslint-plugin-jsonc';

const eslintConfigObjects = [
  {
    /// Globally ignores files and directories. Note that for flat config,
    /// node_modules is ignored by default.
    // '!node_modules' /// unignore node_modules
    ignores: ['**/dist'],
  },
  {
    files: ['**/*.json', '**/*.jsonc', '**/*.json5'],
    plugins: {
      jsonc,
    },
    languageOptions: {
      parser: jsonc,
    },
    rules: {
      ...jsonc.configs['all'].rules,
      'jsonc/auto': 'off',
      /// Allow json files to have comments
      'jsonc/no-comments': 'off',
      /// Indent with 2 spaces
      'jsonc/indent': ['error', 2, {}],
      /// Support arrays with and without new lines but they can't mix
      'jsonc/array-element-newline': ['error', 'consistent'],
      /// Don't sort keys. We want to keep the order of keys as they are:
      /// especially in arrays.
      'jsonc/sort-keys': 'off',
      /// Not all keys are camelCase
      'jsonc/key-name-casing': 'off',
      /// see https://ota-meshi.github.io/eslint-plugin-jsonc/rules/comma-dangle.html
      /// json files should not have dangling commas. Tools like jq will error:
      /// 'jq: parse error: Expected another key-value pair at line 4, column 3'
      // 'jsonc/comma-dangle': ['error', 'never'], /// default
    },
  },
  {
    files: ['**/*.json'],
    plugins: {
      jsonc,
    },
    languageOptions: {
      parser: jsonc,
    },
    rules: {
      /// No matter how much it would be cool to have comments in json files,
      /// it's not supported by the json spec. We get errors tools like jq and
      /// node.
      'jsonc/no-comments': 'error'
    },
  },  
];

export default eslintConfigObjects;
