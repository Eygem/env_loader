# EnvLoader

[![Hex.pm](https://img.shields.io/hexpm/v/env_loader.svg)](https://hex.pm/packages/env_loader)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/Eygem/env_loader/blob/main/LICENSE)
[![Build Status](https://github.com/Eygem/env_loader/actions/workflows/ci.yml/badge.svg)](https://github.com/Eygem/env_loader/actions)

A lightweight, dependency-free Elixir library for loading `.env` files into the system environment. Built for simplicity and robustness, it handles edge cases like comments, quoted values, `EXPORT` directives, empty keys, and inline comments with fewer than 60 lines of code.


## Installation

Add `env_loader` to your `mix.exs` dependencies:
```elixir
{:env_loader, "~> 0.1"}
```
Run mix deps.get to fetch the dependency.

## Usage

`EnvLoader` loads environment variables from `.env` files into the system environment, typically in `config/runtime.exs`. This example loads variables from different files for production and development/testing environments. Variables can then be accessed via `System.get_env/1` or application config.

Add the following to `config/runtime.exs`:

```elixir
import Config
require Logger

env_file = if config_env() == :prod, do: "./envs/.env", else: "./envs/.env.dev"

case EnvLoader.load(env_file) do
  :ok -> Logger.info("Successfully loaded .env file #{env_file}")
  :error -> Logger.error("Failed to load .env file #{env_file}")
end

# Optional: Set application-specific config
config :your_app, encryption_key: System.get_env("ENCRYPTION_KEY") || "default_key"
```

Access loaded variables in your application:
```elixir
# Using System.get_env/1
key = System.get_env("ENCRYPTION_KEY")

# Using application config (if defined)
key = Application.get_env(:your_app, :encryption_key)
```

### Why Use `config/runtime.exs`?

Elixir’s `config/runtime.exs` is evaluated at runtime, just before the application starts, making it ideal for loading environment variables because:
- **Early Execution**: Runs before the supervision tree, ensuring variables are available to all processes.
- **No Compile-Time Dependency**: Unlike `config/config.exs`, it doesn’t require variables during compilation.
- **Idiomatic Elixir**: Integrates with the `Config` module for setting application configs (e.g., `config :your_app, ...`).


## Supported .env Formats

`EnvLoader` handles the following edge cases:
- Quotes (`'value'`, `"value"`)
- `EXPORT` directives (`EXPORT key=value`, `export key=value`)
- Empty lines
- Empty keys and values (`EMPTY_KEY=`, `=value`)
- Full-line comments (`#comment`)
- Inline comments (`key=value #comment`)
- Malformed lines (`MALFORMED`)
- Multiple `=` (`KEY=abc=def`)
- Whitespace (`  KEY  =  value  `)
- Whitespace in values (`key=value with spaces`)

Example `.env` file:

```shell
# Comment
ENCRYPTION_KEY='secret123'
API_KEY="key with spaces"
EMPTY_KEY=
=value
MALFORMED
KEY_WITH_EQUALS=abc=def
EXPORT EXPORT1_KEY="export1"
export EXPORT2_KEY="export2"
SPACED_KEY  =  spaced value
KEY_WITH_COMMENT=value # inline comment
```

Run `mix test` to verify these cases. Expected results:

```elixir
assert System.get_env("ENCRYPTION_KEY") == "secret123"
assert System.get_env("API_KEY") == "key with spaces"
assert System.get_env("EMPTY_KEY") == nil
assert System.get_env("KEY_WITH_EQUALS") == "abc=def"
assert System.get_env("EXPORT1_KEY") == "export1"
assert System.get_env("EXPORT2_KEY") == "export2"
assert System.get_env("SPACED_KEY") == "spaced value"
assert System.get_env("KEY_WITH_COMMENT") == "value"
```

See `test/env_loader_test.exs` for the full test suite.


## Contributing

Contributions are welcome! Please open an issue or pull request on [GitHub](https://github.com/Eygem/env_loader). For major changes, discuss them in an issue first. Ensure tests pass with `mix test`.


## License

Released under the MIT License. See the **[LICENSE](https://github.com/Eygem/env_loader/blob/main/LICENSE)** file for details.

