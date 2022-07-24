defmodule ElixirBackend.Error.BadKey do
  @moduledoc """
  Defines the error raised when an invalid query parameter is used
  """
  defexception [:message]

  @impl true
  def exception(key) do
    msg = "Got an unexpected query parameter: #{key}"
    %__MODULE__{message: msg}
  end
end
