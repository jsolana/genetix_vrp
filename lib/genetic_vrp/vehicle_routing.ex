defmodule GeneticVrp.VehicleRouting do
  @moduledoc """
  A specific problem implementation for Vehicle Routing (VRP)
  It is possible to define different kind of routes:
    - go-home: The same start point and differents end points per vehicle:

    GeneticVrp.VehicleRouting.genotype(size: 11, fix_start: 6)
    %Genetics.Types.Chromosome{
      genes: [6, 9, 1, 5, 6, 4, 0, 2, 6, 7, 8, 3, 6, 10],
      size: 11,
      fitness: 0,
      age: 0
    }

    - go-office: The same end point and differents start point per vehicle:

    GeneticVrp.VehicleRouting.genotype(size: 11, fix_start: 6)
    %Genetics.Types.Chromosome{
      genes: [6, 9, 1, 5, 6, 4, 0, 2, 6, 7, 8, 3, 6, 10],
      size: 11,
      fitness: 0,
      age: 0
    }

    - go-trip: The same start / end point per vehicle (THIS CASE IS WEIRD):

    GeneticVrp.VehicleRouting.genotype(size: 11, fix_start: 6, fix_end: 0)
      %Genetics.Types.Chromosome{
        genes: [6, 10, 9, 0, 6, 3, 1, 0, 6, 4, 5, 0, 6, 8, 7, 0, 6, 2, 0],
        size: 11,
        fitness: 0,
        age: 0
      }

    - random-go: Each vehicle  has its own route with no coincidences (THIS CASE IS WEIRD):

    GeneticVrp.VehicleRouting.genotype(size: 11)
    %Genetics.Types.Chromosome{
      genes: [0, 5, 9, 6, 10, 1, 3, 8, 7, 2, 4],
      size: 11,
      fitness: 0,
      age: 0
    }
  """
  @behaviour Genetics.Problem
  alias Genetics.Types.Chromosome

  require Logger

  @impl true
  def genotype(opts \\ []) do
    # Options
    #  If all vehicles must start in a specific location
    fix_start = Keyword.get(opts, :fix_start, -1)
    # If all vehicles must ends in a specific location
    fix_end = Keyword.get(opts, :fix_end, -1)
    # total number of locations
    size = Keyword.get(opts, :size, 10)
    # standar vehicle capacity
    chunk_size = Keyword.get(opts, :chunk_size, 4)

    %Chromosome{genes: create_genes(fix_start, fix_end, size, chunk_size), size: size}
  end

  # random
  defp create_genes(-1, -1, size, _chunk_size) do
    Enum.shuffle(for index <- 0..(size - 1), do: index)
  end

  # go-office
  defp create_genes(-1, fix_end, size, chunk_size)
       when is_integer(fix_end) and fix_end >= 0 and fix_end < size do
    Enum.shuffle(for(index <- 0..(size - 1), do: index))
    |> Enum.filter(fn x -> x != fix_end end)
    |> Enum.chunk_every(chunk_size)
    |> Enum.map(fn sublist -> sublist ++ [fix_end] end)
    |> List.flatten()
  end

  # go-home
  defp create_genes(fix_start, -1, size, chunk_size)
       when is_integer(fix_start) and fix_start >= 0 and fix_start < size do
    Enum.shuffle(for(index <- 0..(size - 1), do: index))
    |> Enum.filter(fn x -> x != fix_start end)
    |> Enum.chunk_every(chunk_size)
    |> Enum.map(fn sublist -> [fix_start] ++ sublist end)
    |> List.flatten()
  end

  # go-trip
  defp create_genes(fix_start, fix_end, size, chunk_size)
       when is_integer(fix_start) and fix_start >= 0 and fix_start < size and
              is_integer(fix_end) and fix_end >= 0 and fix_end < size and fix_start != fix_end do
    Enum.shuffle(for(index <- 0..(size - 1), do: index))
    |> Enum.filter(fn x -> x != fix_start and x != fix_end end)
    |> Enum.chunk_every(chunk_size - 1)
    |> Enum.map(fn sublist -> [fix_start] ++ sublist ++ [fix_end] end)
    |> List.flatten()
  end

  @impl true
  def fitness_function(chromosome, opts \\ []) do
    fix_start = Keyword.get(opts, :fix_start, -1)
    fix_end = Keyword.get(opts, :fix_end, -1)
    chunk_size = Keyword.get(opts, :chunk_size, 4)

    if chromosome_is_valid(chromosome, fix_start, fix_end, chunk_size) do
      matrix = Keyword.get(opts, :matrix)

      pairs =
        chromosome.genes
        # TODO
        |> Enum.chunk_every(chunk_size + 1)
        |> Enum.reduce([], fn sublist, acc ->
          (acc ++ Enum.chunk_every(sublist, 2, 1, :discard))
          |> Enum.filter(&(length(&1) == 2))
          |> Enum.map(&Enum.slice(&1, 0, 2))
        end)

      # Logger.info(
      #  "Chromosome: #{inspect(chromosome.genes)}\n\nPairs: #{inspect(pairs)}\n\n#{inspect(matrix)}"
      # )

      pairs
      |> Enum.reduce([], fn [x, y], acc ->
        {distance, _duration} = Map.get(matrix, {x, y}, {0, 0})
        [distance] ++ acc
      end)
      |> Enum.sum()
    else
      # max integer
      :math.pow(2, 63) - 1
    end
  end

  defp chromosome_is_valid(_chromosome, -1, -1, _chunk_size), do: true

  defp chromosome_is_valid(chromosome, fix_start, -1, chunk_size) do
    chromosome.genes
    |> Enum.chunk_every(chunk_size + 1)
    |> Enum.all?(&(List.first(&1) == fix_start))
  end

  defp chromosome_is_valid(chromosome, -1, fix_end, chunk_size) do
    chromosome.genes
    |> Enum.chunk_every(chunk_size + 1)
    |> Enum.all?(&(List.last(&1) == fix_end))
  end

  defp chromosome_is_valid(chromosome, fix_start, fix_end, chunk_size) do
    chromosome.genes
    |> Enum.chunk_every(chunk_size + 1)
    |> Enum.all?(&(List.last(&1) == fix_end and List.first(&1) == fix_start))
  end

  @impl true
  def terminate?([best | _], opts \\ []) do
    max_generation = Keyword.get(opts, :max_generation, 10_000)
    IO.write("\r#{inspect(best.fitness)}")
    best.age == max_generation
  end

  def custom_crossover(population, _opts \\ []) do
    # Logger.info("Custom crossover with population: #{inspect(population)} and opts: #{inspect(opts)}")
    # def mezclar_con_valor_fijo(lista, valor_fijo) do
    # sin_valor_fijo = lista |> Enum.filter(&(&1 != valor_fijo))
    # mezclado = sin_valor_fijo |> Enum.shuffle()
    # index_valor_fijo = Enum.random(0..length(mezclado))
    # Enum.insert_at(mezclado, index_valor_fijo, valor_fijo)
    # end

    # TODO
    population
    |> Enum.reduce(
      [],
      fn {p1, p2}, acc ->
        # Logger.info("p1: #{inspect(p1)} p2: #{inspect(p2)} acc: #{inspect(acc)}")
        [p1, p2 | acc]
      end
    )
  end

  def custom_mutation(population, _opts \\ []) do
    # Logger.info("Custom mutation with population: #{inspect(population)} and opts: #{inspect(opts)}")

    # TODO
    population
    |> Enum.map(fn chromosome -> chromosome end)
  end
end
