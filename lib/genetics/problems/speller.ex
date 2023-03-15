defmodule Genetics.Problems.Speller do
  @moduledoc """
  A specific problem implementation to obtain @target (a-z no whitespaces / Uppercases / etc.)
  ## Run the problem

  ```
    Genetics.Evolution.run(Genetics.Problems.Speller, target: "elixir")
  ```
  """
  @behaviour Genetics.Problem
  alias Genetics.Types.Chromosome

  @default_target "elixir"
  @impl true
  def genotype(opts \\ []) do
    target = Keyword.get(opts, :target, @default_target)
    size = String.length(target)

    genes =
      Stream.repeatedly(fn -> Enum.random(?a..?z) end)
      |> Enum.take(size)

    %Chromosome{genes: genes, size: size}
  end

  @impl true
  def fitness_function(chromosome, opts \\ []) do
    target = Keyword.get(opts, :target, @default_target)
    guess = List.to_string(chromosome.genes)
    String.jaro_distance(target, guess)
  end

  @impl true
  def terminate?([best | _], _opts \\ []) do
    IO.write("\r#{inspect(best.fitness)}")
    best.fitness == 1
  end
end
