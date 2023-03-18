defmodule Genetics.Evolution.Evaluate do
  @moduledoc """
  Contain functions with different aproaches to make the selection

  https://en.wikipedia.org/wiki/Selection_(genetic_algorithm)

  """

  alias Genetics.Types.Chromosome

  require Logger

  def heuristic_evaluation(population, fitness_function, opts \\ []) do
    sort_criteria = Keyword.get(opts, :sort_criteria, &>=/2)

    population
    |> Enum.map(fn chromosome ->
      fitness = fitness_function.(chromosome, opts)
      age = chromosome.age + 1

      # IO.gets("Fitness function for #{inspect(chromosome)}\nResult: #{inspect(fitness)}\nPress Enter to continue...")

      %Chromosome{chromosome | fitness: fitness, age: age}
    end)
    |> Enum.sort_by(& &1.fitness, sort_criteria)
  end
end
