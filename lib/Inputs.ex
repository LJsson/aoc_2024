defmodule Inputs do
  @moduledoc false
  @cache_path "~/.cache/advent_of_code"

  @spec get(non_neg_integer() | atom(), non_neg_integer()) ::
          {:ok, String.t()} | {:error, String.t()}
  def get(day, year \\ 0)

  def get(module_string, _) when is_atom(module_string) do
    {day, year} = get_info_from_module(module_string)

    get(day, year)
  end

  def get(day, _) when day > 25 or day < 1, do: {:error, "Invalid day: #{day}"}

  def get(day, year) do
    cond do
      in_cache?(day, year) -> get_cache(day, year)
      has_session_cookie?() -> download(day, year)
      true -> {:error, "wrong"}
    end
  end

  @spec get_info_from_module(atom()) :: {integer(), integer()}
  defp get_info_from_module(module) do
    [year_chunk, day_chunk, _] =
      module
      |> Atom.to_string()
      |> String.replace_leading("Elixir.AdventOfCode.Solutions.", "")
      |> String.split(".")

    {
      day_chunk |> String.replace("Day", "") |> String.to_integer(),
      year_chunk |> String.replace("Year", "") |> String.to_integer()
    }
  end

  @spec filepath(non_neg_integer(), non_neg_integer()) :: String.t()
  defp filepath(day, year),
    do: Path.join([@cache_path, "year#{year}day#{day}"]) |> Path.expand()

  @spec in_cache?(non_neg_integer(), non_neg_integer()) :: boolean()
  defp in_cache?(day, year), do: File.exists?(filepath(day, year))

  @spec get_cache(non_neg_integer(), non_neg_integer()) ::
          {:ok, String.t()} | {:error, String.t()}
  defp get_cache(day, year) do
    case File.read(filepath(day, year)) do
      {:ok, contents} -> {:ok, contents}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec has_session_cookie?() :: boolean()
  defp has_session_cookie?(), do: session_cookie() != nil

  defp download(day, year) do
    case HTTPoison.get("https://adventofcode.com/#{year}/day/#{day}/input", headers()) do
      {:ok, %{status_code: 200} = response} -> save_to_cache(day, year, response.body)
      {:error, reason} -> {:error, reason}
    end
  end

  defp save_to_cache(day, year, contents) do
    path = filepath(day, year) |> Path.dirname()

    File.mkdir_p(path)
    File.write(filepath(day, year), contents)

    {:ok, contents}
  end

  defp config, do: Application.get_env(:advent_of_code, __MODULE__)
  defp session_cookie, do: Keyword.get(config(), :session_cookie, nil)

  defp headers, do: [{"cookie", "session=#{session_cookie()}"}]
end
