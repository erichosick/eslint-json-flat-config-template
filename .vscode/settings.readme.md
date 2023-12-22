# Visual Studio Code Settings

## ESLint Configuration

### `eslint.options.overrideConfigFile`
- **Description**: Specify the name of the ESLint configuration file to use. Enables us to use the extended configuration along with using an ECMAScript file.
- **See also**: [ESLint Node.js API](https://eslint.org/docs/latest/integrate/nodejs-api#-new-eslintoptions)

### `eslint.experimental.useFlatConfig`
- **Description**: Enables using newer flat ESLint files (e.g., `eslint.config.js`).

## ESLint JSON Validation Configuration

### `json.validate.enable`
- **Description**: Disable validation of JSON files using VS Code's built-in JSON validator.
- **See also**: [VS Code JSON Language Features](https://code.visualstudio.com/Docs/languages/json#_intellisense-and-validation)

### `eslint.validate`
- **Description**: Configure ESLint to validate the provided file types. Default for non-flat configuration is `.js`, `.mjs`, and `.cjs`.

## ESLint as a Formatter Configuration

### `[{extension}].editor.defaultFormatter`
- **Description**: Assure other formatters are not used by setting ESLint as the default formatter: setting the default formatter to `dbaeumer.vscode-eslint`.

### `eslint.format.enable`
- **Description**: Enables ESLint to do code formatting in VS Code.

## Editor Configuration

### `editor.codeActionsOnSave`
- **Description**: Enables fixing of code in the editor before saving.

### `editor.formatOnSave`
- **Description**: Enables auto format on save.
- **See also**: [VSCode ESLint Extension](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)


## Why This Document

Documenting options in `settings.json` help others come up to speed faster.

* Files with `json` extensions can not have comments.
* Adding new properties to `settings.json` results in a warning as `settings.json` have a schema (see [Preferences](https://github.com/microsoft/vscode/blob/2ae55bc71641241d99cd1c79849c9823426790f2/src/vs/workbench/services/preferences/common/preferences.ts)).
* Visual Studio Code does not support `settings.jsonc` or `settings.json5`
