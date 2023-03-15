defmodule Genetics.Evolution do
  @moduledoc """
  Structure of a genetic algorithm in Elixir.
  The process of creating an algorithm can be thought of in three phases:
    1. Problem Definition
    2. Evolution Definition
    3. Algorithm Execution

  To define a `Problem`  you need to define the specifi-problems funtions:
    1. Define your solution space (`genotype/1`).
    2. Define your objective function (`fitness_function/2`).
    3. Define your termination criteria (`terminate?/2`).

  ## Implementing a Problem
  A basic genetic  problem consists of: `genotype/0`, `fitness_function/1`, and `terminate?/1`.
  ```
  defmodule OneMax do
    @behaviour Genetics.Problem
    alias Genetics.Types.Chromosome

    @impl true
    def genotype(opts \\ []) do
      size = Keyword.get(opts, :size, 10)
      genes = for _ <- 1..42, do: Enum.random(0..1)
      %Chromosome{genes: genes, size: size}
    end

    @impl true
    def fitness_function(chromosome, _opts \\ []), do: Enum.sum(chromosome.genes)

    @impl true
    def terminate?([best | _], _opts \\ []) do
      best.fitness == best.size
    end
  end
  ```

  ## Hyperparameters

  It is also possible to define hyperparameters to configure the algorithm.

  ## Run the problem

  ```
    Evolution.run(OneMax)
  ```

  """
  alias Genetics.Evolution.{CrossOver, Mutation, Select, Evaluate}

  require Logger

  def run(problem, opts \\ []) do
    Logger.info("Running #{inspect(problem)} with opts: #{inspect(opts)}")
    population = initialize(&problem.genotype/1, opts)

    population
    |> evolve(problem, opts)
  end

  def evolve(population, problem, opts \\ []) do
    population = evaluate(population, &problem.fitness_function/2, opts)
    best = hd(population)
    # IO.write("\rCurrent Best: #{fitness_function.(best)}")

    if problem.terminate?(population, opts) do
      IO.write("\r")
      best
    else
      population
      |> select(opts)
      |> crossover(opts)
      |> mutation(opts)
      |> evolve(problem, opts)
    end
  end

  def initialize(genotype, opts \\ []) do
    population_size = Keyword.get(opts, :population_size, 100)
    for _ <- 1..population_size, do: genotype.(opts)
  end

  def evaluate(population, fitness_function, opts \\ []) do
    evaluate_operator = Keyword.get(opts, :evaluate_type, &Evaluate.heuristic_evaluation/3)
    evaluate_operator.(population, fitness_function, opts)
  end

  def select(population, opts \\ []) do
    select_operator = Keyword.get(opts, :select_type, &Select.select_elite/2)
    select_operator.(population, opts)
  end

  def crossover(population, opts \\ []) do
    crossover_operator = Keyword.get(opts, :crossover_type, &CrossOver.crossover_cx_one_point/2)
    crossover_operator.(population, opts)
  end

  def mutation(population, opts \\ []) do
    mutation_operator = Keyword.get(opts, :mutation_type, &Mutation.mutation_shuffle/2)
    mutation_operator.(population, opts)
  end
end
