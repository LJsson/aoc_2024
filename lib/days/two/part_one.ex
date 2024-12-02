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
    |> Enum.map(&is_safe?/1)
    |> Enum.reject(&(&1 == false))
    |> Enum.count()
  end

  def test(), do: solve(@test_input)

  def run(), do: solve(Input.get(2024, 2))

  defp is_safe?(levels) do
    levels
    |> Enum.take(2)
    |> case do
      [first, second] when first < second ->
        iterate_level(levels, :plus)

      [first, second] when first > second ->
        iterate_level(levels, :minus)
    end
  end

  defp iterate_level(levels, :plus) do
    levels
    |> Enum.reduce_while(nil, fn
      level, nil ->
        {:cont, level}

      level, prev when level - prev <= 3 and level - prev > 0 ->
        {:cont, level}

      _, _ ->
        {:halt, false}
    end) != false
  end

  defp iterate_level(levels, :minus) do
    levels
    |> Enum.reduce_while(nil, fn
      level, nil ->
        {:cont, level}

      level, prev when level - prev >= -3 and level - prev < 0 ->
        {:cont, level}

      _, _ ->
        {:halt, false}
    end) != false
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
