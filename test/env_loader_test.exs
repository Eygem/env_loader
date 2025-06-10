defmodule EnvLoaderTest do
  use ExUnit.Case
  import EnvLoader
  doctest EnvLoader

  test "loads .env file with various formats" do
    File.write!("test.env", """
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
    """)

    assert :ok = load("test.env")
    assert System.get_env("ENCRYPTION_KEY") == "secret123"
    assert System.get_env("API_KEY") == "key with spaces"
    assert System.get_env("EMPTY_KEY") == nil
    assert System.get_env("KEY_WITH_EQUALS") == "abc=def"
    assert System.get_env("EXPORT1_KEY") == "export1"
    assert System.get_env("EXPORT2_KEY") == "export2"
    assert System.get_env("SPACED_KEY") == "spaced value"
    assert System.get_env("KEY_WITH_COMMENT") == "value"

    File.rm!("test.env")
  end

  test "returns :error for missing file" do
    assert :error = load("nonexistent.env")
  end
end
