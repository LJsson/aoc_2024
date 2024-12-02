defmodule AOC2024.Days.Two.PartOne do
  @moduledoc false
  alias AOC2024.Input

  @test_input """
  7 6 4 2 1
  1 2 7 8 9
  9 7 6 2 1
  1 3 2 4 5
  8 6 4 4 1
  1 3 6 7 9
  """

  def solve(input) do
    input
    |> parse_input
    |> Enum.map(&safe?/1)
    |> Enum.reject(&(&1 == false))
    |> Enum.count()
  end

  def test(), do: solve(@test_input)

  def run(), do: solve(Input.get(2024, 2))

  defp safe?(levels) do
    levels
    |> Enum.reduce_while({nil, nil}, fn
      level, {nil, prev} when is_nil(prev) ->
        {:cont, {nil, level}}

      level, {nil, prev} ->
        detect_trend(level, prev)

      level, {trend, prev} ->
        validate_trend(level, prev, trend)
    end) != false
  end

  defp detect_trend(level, prev) do
    case level - prev do
      diff when diff > 0 and diff <= 3 -> {:cont, {:plus, level}}
      diff when diff < 0 and diff >= -3 -> {:cont, {:minus, level}}
      _ -> {:halt, false}
    end
  end

  defp validate_trend(level, prev, :plus) do
    if level - prev > 0 and level - prev <= 3, do: {:cont, {:plus, level}}, else: {:halt, false}
  end

  defp validate_trend(level, prev, :minus) do
    if level - prev < 0 and level - prev >= -3, do: {:cont, {:minus, level}}, else: {:halt, false}
  end

  defp parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn x ->
      x
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)
    end)
  end
end
