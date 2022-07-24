defmodule ElixirBackend.LibObj.Query do
  @moduledoc """
  Utility functions for verifying query parameters.
  """

  alias ElixirBackend.Error.{BadKey, ImproperKey}

  @spec check_mutually_exclusive!(params :: map(), any(), [any()]) :: :ok | no_return()
  def check_mutually_exclusive!(params, limiter, improper_keys)
      when is_map_key(params, limiter) do
    Enum.each(improper_keys, fn improper_key ->
      if is_map_key(params, improper_key) do
        raise ImproperKey, {limiter, improper_key}
      end
    end)

    :ok
  end

  def check_mutually_exclusive!(params, _limiter, _improper_keys) when is_map(params) do
    :ok
  end

  @spec validate_keys!(params :: map(), valid_keys :: [any()]) :: :ok | no_return()
  def validate_keys!(params, valid_keys) when is_map(params) and is_list(valid_keys) do
    param_keys = Map.keys(params)

    Enum.each(param_keys, fn param_key ->
      if param_key not in valid_keys do
        raise BadKey, param_key
      end
    end)

    :ok
  end
end
