defmodule Genetics.Problems.NQueens do
  @moduledoc """
  A specific genetic problem implementation for NQueens.
  The N Queen is a combinatorial optimization problem, the objective is to configure NQueens on chess board so that no queen theatens another.any()

  Hyperparameters

    - `size` number of queens. Default `8`.

  ## Examples

    iex> Genetics.Evolution.run(Genetics.Problems.NQueens, size: 8)

  """
  @behaviour Genetics.Problem
  alias Genetics.Types.Chromosome

  @impl true
  def genotype(opts \\ []) do
    size = Keyword.get(opts, :size, 8)
    genes = Enum.shuffle(0..(size - 1))
    %Chromosome{genes: genes, size: size}
  end

  @impl true
  def fitness_function(chromosome, opts \\ []) do
    size = Keyword.get(opts, :size, 8)

    diag_clashes =
      for i <- 0..(size - 1), j <- 0..(size - 1) do
        if i != j do
          dx = abs(i - j)

          dy =
            abs(
              chromosome.genes
              |> Enum.at(i)
              |> Kernel.-(Enum.at(chromosome.genes, j))
            )

          if dx == dy do
            1
          else
            0
          end
        else
          0
        end
      end

    length(Enum.uniq(chromosome.genes)) - Enum.sum(diag_clashes)
  end

  @impl true
  def terminate?([best | _], _opts \\ []) do
    IO.write("\r#{inspect(best.fitness)}")
    best.fitness == best.size
  end
end
