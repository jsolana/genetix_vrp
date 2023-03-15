defmodule Genetics.Evolution.Select do
  @moduledoc """
  Contain functions with different aproaches to make the selection

  https://en.wikipedia.org/wiki/Selection_(genetic_algorithm)

  """

  # alias Genetics.Types.Chromosome

  require Logger

  def select_elite(population, _opts \\ []) do
    population
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple(&1))
  end
end
