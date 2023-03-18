defmodule Genetics.Evolution.Mutation do
  @moduledoc """
  Contains functions with different aproaches to make the mutation

  https://en.wikipedia.org/wiki/Mutation_(genetic_algorithm)

  """
  alias Genetics.Types.Chromosome

  require Logger

  def mutation_shuffle(population, opts \\ []) do
    mutation_probability = Keyword.get(opts, :mutation_probability, 0.05)

    population
    |> Enum.map(fn chromosome ->
      if :rand.uniform() < mutation_probability do
        %Chromosome{chromosome | genes: Enum.shuffle(chromosome.genes)}
      else
        chromosome
      end
    end)
  end
end
