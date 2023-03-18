defmodule Genetics.Evolution.CrossOver do
  @moduledoc """
  Contain functions with different aproaches to make the crossover

  https://en.wikipedia.org/wiki/Crossover_(genetic_algorithm)

  """
  alias Genetics.Types.Chromosome

  require Logger

  def crossover_cx_one_point(population, _opts) do
    population
    |> Enum.reduce(
      [],
      fn {p1, p2}, acc ->
        cx_point = :rand.uniform(length(p1.genes))
        {{h1, t1}, {h2, t2}} = {Enum.split(p1.genes, cx_point), Enum.split(p2.genes, cx_point)}
        {c1, c2} = {%Chromosome{p1 | genes: h1 ++ t2}, %Chromosome{p2 | genes: h2 ++ t1}}
        [c1, c2 | acc]
      end
    )
  end

  # Crossover for permutations
  def crossover_cx_ordered(population, _opts \\ []) do
    population
    |> Enum.reduce(
      [],
      fn {p1, p2}, acc ->
        cx_start = Enum.random(0..(length(population) - 1))
        cx_end = Enum.random((cx_start + 1)..(length(population) - 1))
        offspring1_genes = (Enum.slice(p1.genes, cx_start, cx_end) ++ p2.genes) |> Enum.uniq()
        offspring2_genes = (Enum.slice(p2.genes, cx_start, cx_end) ++ p1.genes) |> Enum.uniq()

        {c1, c2} =
          {%Chromosome{p1 | genes: offspring1_genes}, %Chromosome{p2 | genes: offspring2_genes}}

        [c1, c2 | acc]
      end
    )
  end
end
