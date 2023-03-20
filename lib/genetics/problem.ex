defmodule Genetics.Problem do
  @moduledoc """
  Genetic problem behaviour definition with the problem-specific functions that a problem must to provide:
    - Fitness function
    - Genotype
    - Termination criteria

    These functions allow `hyperparameters` to allow controls how the algorithm works as population size, mutation rate.
    Each Problem implementation can define and document its hyperparameters.

    Common hyperparameters:
      - `evaluation_type`:      Evaluation operator. By default `heuristic_evaluation/3`.
      - `select_type`:          Selection operator. By default `select_elite/3`.
      - `select_rate`:          Selection rate. By default `0.8`.
      - `crossover_type`:       Crossover operator. By defaul `crossover_cx_one_point/3`. To run successfully this problem, you need to override this property using `custom_crossover` function.
      - `mutation_type`:        Mutation operator. By default `mutation_shuffle/2`. To run successfully this problem, you need to override this property using `custom_mutation` function.
      - `mutation_probability`: Mutation probability. By defaul `0.05`.
      - `sort_criteria`:        How to sort the population by its fitness score (max or min). By default max first.

    Optional hyperparameters:

      - `size`:                 Total number of locations. By default `10`.
      - `population_size`:      Total number of individuals to run the algorithm. By default `100`.

  """
  @type hyperparameters :: keyword()
  alias Genetics.Types.Chromosome

  @callback genotype(hyperparameters) :: Chromosome.t()
  @callback fitness_function(Chromosome.t(), hyperparameters) :: number()
  @callback terminate?(Enum.t(), hyperparameters) :: boolean()
end
