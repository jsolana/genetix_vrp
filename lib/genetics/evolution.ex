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
    Logger.info("Running #{inspect(problem)}")
    # Logger.info("opts: #{inspect(opts)}")
    population = initialize(&problem.genotype/1, opts)

    population
    |> evolve(problem, opts)
  end

  def initialize(genotype, opts \\ []) do
    population_size = Keyword.get(opts, :population_size, 100)
    population = for _ <- 1..population_size, do: genotype.(opts)
    # IO.gets("Population: #{inspect(population)}\nPress Enter to continue...")
    population
  end

  def evolve(population, problem, opts \\ []) do
    population = evaluate(population, &problem.fitness_function/2, opts)
    best = hd(population)
    # IO.write("\rCurrent Best: #{fitness_function.(best)}")
    # IO.gets("Population evolved: #{inspect(population)}\nCurrent Best: #{inspect(best)}\nPress Enter to continue...")

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

  def evaluate(population, fitness_function, opts \\ []) do
    evaluate_operator = Keyword.get(opts, :evaluate_type, &Evaluate.heuristic_evaluation/3)
    result = evaluate_operator.(population, fitness_function, opts)
    # IO.gets("Evaluate result: #{inspect(result)}\nPress Enter to continue...")
    result
  end

  def select(population, opts \\ []) do
    select_operator = Keyword.get(opts, :select_type, &Select.select_elite/2)
    result = select_operator.(population, opts)
    # IO.gets("Select result: #{inspect(result)}\nPress Enter to continue...")
    result
  end

  def crossover(population, opts \\ []) do
    crossover_operator = Keyword.get(opts, :crossover_type, &CrossOver.crossover_cx_one_point/2)
    result = crossover_operator.(population, opts)
    # IO.gets("Crossover result: #{inspect(result)}\nPress Enter to continue...")
    result
  end

  def mutation(population, opts \\ []) do
    mutation_operator = Keyword.get(opts, :mutation_type, &Mutation.mutation_shuffle/2)
    result = mutation_operator.(population, opts)
    # IO.gets("Mutation result: #{inspect(result)}\nPress Enter to continue...")
    result
  end
end
