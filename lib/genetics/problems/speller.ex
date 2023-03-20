defmodule Genetics.Problems.Speller do
  @moduledoc """
  A specific problem implementation to obtain @target (a-z no whitespaces) string.

  Hyperparameters

    - `target` an a-z no whitespaces string. By default `elixir`.
    - `max_generation, termination criteria. By default `10_000`.

  ## Examples

    iex> Genetics.Evolution.run(Genetics.Problems.Speller, target: "elixir", max_generation: 1)

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
  def terminate?([best | _], opts \\ []) do
    max_generation = Keyword.get(opts, :max_generation, 10_000)
    IO.write("\r#{inspect(best.fitness)}")
    best.fitness == 1 || best.age == max_generation
  end
end
