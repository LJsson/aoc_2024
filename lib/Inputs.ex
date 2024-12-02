defmodule AOC2024.Input do
  @moduledoc false

  @base_url "https://adventofcode.com"
  @cache_dir "aoc_inputs"

  @doc """
  Fetches the input for a given year and day, caching it for future use.

  ## Parameters
    - `year` (integer): The year of the challenge.
    - `day` (integer): The day of the challenge.

  ## Example
      iex> AdventOfCode.Input.get(2024, 1)
  """
  def get(year, day) do
    ensure_cache_dir()

    file_path = cache_file_path(year, day)

    case File.read(file_path) do
      {:ok, content} ->
        content

      {:error, _reason} ->
        fetch_and_cache_input(year, day, file_path)
    end
  end

  defp fetch_and_cache_input(year, day, file_path) do
    case fetch_input(year, day) do
      {:ok, input} ->
        File.write!(file_path, input)
        input

      {:error, reason} ->
        raise(reason)
    end
  end

  defp fetch_input(year, day) do
    session_cookie = System.get_env("AOC_SESSION")

    url = "#{@base_url}/#{year}/day/#{day}/input"
    headers = [{"cookie", "session=#{session_cookie}"}]

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: status}} ->
        {:error, "Failed with status code #{status}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP request failed: #{inspect(reason)}"}
    end
  end

  defp ensure_cache_dir do
    File.mkdir_p!(@cache_dir)
  end

  defp cache_file_path(year, day) do
    "#{@cache_dir}/#{year}_day_#{day}.txt"
  end
end
