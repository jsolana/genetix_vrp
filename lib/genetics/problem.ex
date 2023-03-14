defmodule Genetics.Problem do
  @moduledoc """
  Genetic problem behaviour definition with the problem-specific functions that a problem must to provide:
    - Fitness function
    - Genotype
    - Termination criteria

    These functions allow `hyperparameters` to allow controls how the algorithm works as population size, mutation rate.
    Each Problem implementation can define and document its hyperparameters.
  """
  @type hyperparameters :: keyword()
  alias Genetics.Types.Chromosome

  @callback genotype(hyperparameters) :: Chromosome.t()
  @callback fitness_function(Chromosome.t(), hyperparameters) :: number()
  @callback terminate?(Enum.t(), hyperparameters) :: boolean()
end
