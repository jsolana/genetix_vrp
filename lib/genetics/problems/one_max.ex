defmodule Genetics.Problems.OneMax do
  @moduledoc """
  A specific genetic problem implementation for OneMax.
  The One-Max problem is a trivial problem: What is the maximum sum of a bitstring (a string consisting of only 1s and 0s) of length N.

  ## Run the problem

  ```
    Genetics.Evolution.run(Genetics.Problems.OneMax, size: 1000)
  ```
  """
  @behaviour Genetics.Problem
  alias Genetics.Types.Chromosome

  @impl true
  def genotype(opts \\ []) do
    size = Keyword.get(opts, :size, 42)
    genes = for _ <- 1..size, do: Enum.random(0..1)
    %Chromosome{genes: genes, size: size}
  end

  @impl true
  def fitness_function(chromosome, _opts \\ []), do: Enum.sum(chromosome.genes)

  @impl true
  def terminate?([best | _], _opts \\ []) do
    IO.write("\r#{inspect(best.fitness)}")
    best.fitness == best.size
  end
end
