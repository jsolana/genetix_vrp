defmodule Genetics.Evolution.Evaluate do
  @moduledoc """
  Contain functions with different aproaches to make the selection

  https://en.wikipedia.org/wiki/Selection_(genetic_algorithm)

  """

  alias Genetics.Types.Chromosome

  require Logger

  def heuristic_evaluation(population, fitness_function, opts \\ []) do
    population
    |> Enum.map(fn chromosome ->
      fitness = fitness_function.(chromosome, opts)
      age = chromosome.age + 1
      %Chromosome{chromosome | fitness: fitness, age: age}
    end)
    |> Enum.sort_by(& &1.fitness, &>=/2)
  end
end
