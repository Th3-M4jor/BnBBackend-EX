defmodule ElixirBackend.Error.ImproperKey do
  @moduledoc """
  Defines the error raised when a query parameter conflicts
  with another query parameter.
  """

  defexception [:message]

  @impl true
  def exception({limiter, improper_key}) do
    msg = "Query parameters #{limiter} and #{improper_key} are mutually exclusive"
    %__MODULE__{message: msg}
  end
end
