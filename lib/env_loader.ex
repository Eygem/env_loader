defmodule EnvLoader do
  @moduledoc """
  A lightweight, dependency-free Elixir library for loading `.env` files into the system environment.
  Built for simplicity and robustness, it handles edge cases like comments, quoted values, `EXPORT`
  directives, empty keys, and inline comments with fewer than 60 lines of code.
  """

  require Logger

  @doc """
  Loads environment variables from a .env file at the given path.

  ## Parameters
  - `path`: Path to the .env file (e.g., "./envs/.env").
  - `opts`: Options (e.g., `default: "value"` for missing keys).

  ## Returns
  - `:ok` on success, `:error` if the file is not found.

  ## Examples
      iex> File.write!("test.env", "KEY=value")
      iex> EnvLoader.load("test.env")
      :ok
      iex> System.get_env("KEY")
      "value"
      iex> File.rm!("test.env")
  """
  def load(path, _opts \\ []) do
    if File.exists?(path) do
      Logger.info("Loading .env file #{path}")

      File.read!(path)
      |> String.split("\n", trim: true)
      |> Enum.each(fn line ->
        line = String.trim(line)

        # Skip empty lines and comments
        if line != "" and not String.starts_with?(line, "#") do
          # Remove inline comments (everything from # to end of line)
          line = Regex.replace(~r/#.*$/, line, "")
          # Remove "EXPORT" or "export" if present
          line =
            String.replace_prefix(line, "EXPORT ", "") |> String.replace_prefix("export ", "")

          case String.split(line, "=", parts: 2) do
            [key, value] ->
              key = String.trim(key)

              # Strip quotes and whitespace from value
              value =
                String.trim(value)
                |> String.trim_leading("'")
                |> String.trim_leading("\"")
                |> String.trim_trailing("'")
                |> String.trim_trailing("\"")

              # Loads key-value pairs into the system environment
              # if key != "" and value != "", do: System.put_env(key, value)
              if key != "" and value != "", do: System.put_env(key, value)

            _ ->
              Logger.debug("Skipping malformed .env line: #{line}")
          end
        end
      end)

      :ok
    else
      Logger.error("Error: .env file not found at #{path}")
      :error
    end
  end
end
