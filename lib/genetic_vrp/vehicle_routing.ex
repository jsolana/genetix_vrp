defmodule GeneticVrp.VehicleRouting do
  @moduledoc """
  A specific problem implementation for Vehicle Routing (VRP)
  It is possible to define different kind of routes:
    - go-home: The same start point and differents end points per vehicle:

    GeneticVrp.VehicleRouting.genotype(size: 10, fix_start: 6)
    %Genetics.Types.Chromosome{
      genes: [6, 9, 1, 5, 6, 4, 0, 2, 6, 7, 8, 3, 6, 10],
      size: 10,
      fitness: 0,
      age: 0
    }

    - go-office: The same end point and differents start point per vehicle:

    GeneticVrp.VehicleRouting.genotype(size: 10, fix_start: 6)
    %Genetics.Types.Chromosome{
      genes: [6, 9, 1, 5, 6, 4, 0, 2, 6, 7, 8, 3, 6, 10],
      size: 10,
      fitness: 0,
      age: 0
    }

    - go-trip: The same start / end point per vehicle (THIS CASE IS WEIRD):

    GeneticVrp.VehicleRouting.genotype(size: 10, fix_start: 6, fix_end: 0)
      %Genetics.Types.Chromosome{
        genes: [6, 10, 9, 0, 6, 3, 1, 0, 6, 4, 5, 0, 6, 8, 7, 0, 6, 2, 0],
        size: 10,
        fitness: 0,
        age: 0
      }

    - random-go: Each vehicle  has its own route with no coincidences (THIS CASE IS WEIRD):

    GeneticVrp.VehicleRouting.genotype(size: 10)
    %Genetics.Types.Chromosome{
      genes: [0, 5, 9, 6, 10, 1, 3, 8, 7, 2, 4],
      size: 10,
      fitness: 0,
      age: 0
    }

    To generate a population

    population = for _ <- 1..2, do: GeneticVrp.VehicleRouting.genotype(size: 10)

  """
  @behaviour Genetics.Problem
  alias Genetics.Types.Chromosome
  alias Genetics.Evolution.{CrossOver, Mutation}
  alias GeneticVrp.Utils

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

      result =
        pairs
        |> Enum.reduce([], fn [x, y], acc ->
          {distance, _duration} = Map.get(matrix.matrix, {x, y}, {0, 0})

          [distance] ++ acc
        end)
        |> Enum.sum()

      # IO.gets("Calculating fitness function for chromosome #{inspect(chromosome)}\nPairs: #{inspect(pairs)}\nresult: #{inspect(result)}\nPress enter to continue...")

      result
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

  def custom_crossover(population, opts \\ []) do
    # Logger.info("Custom crossover with population: #{inspect(population)} and opts: #{inspect(opts)}")
    fix_start = Keyword.get(opts, :fix_start, -1)
    fix_end = Keyword.get(opts, :fix_end, -1)
    crossover(population, fix_start, fix_end, opts)
  end

  defp crossover(population, -1, -1, opts) do
    CrossOver.crossover_cx_ordered(population, opts)
  end

  defp crossover(population, _fix_start, _fix_end, opts) do
    chunk_size = Keyword.get(opts, :chunk_size, 4) + 1

    population
    |> Enum.reduce(
      [],
      fn {p1, p2}, acc ->
        chunks_p1 = Enum.chunk_every(p1.genes, chunk_size)
        chunks_p2 = Enum.chunk_every(p2.genes, chunk_size)

        if length(chunks_p1) > 1 do
          # IO.gets("chunks1: #{inspect(chunks_p1)}\n chunks2: #{inspect(chunks_p2)}\nPress enter continue...")
          cx_point1 = :rand.uniform(length(chunks_p1))
          cx_point2 = Utils.random_allow_number([cx_point1], size: length(chunks_p2))
          chunks_p1 = chunks_p1 |> List.replace_at(cx_point1, Enum.at(chunks_p2, cx_point1))
          chunks_p2 = chunks_p2 |> List.replace_at(cx_point2, Enum.at(chunks_p1, cx_point2))

          # IO.gets("chunks1: #{inspect(chunks_p1)}\n chunks2: #{inspect(chunks_p2)}\ncx_point1: #{inspect(cx_point1)} and cx_point2: #{inspect(cx_point2)}\nPress enter continue...")
        end

        {c1, c2} =
          {%Chromosome{p1 | genes: Enum.reduce(chunks_p1, [], fn chunk, acc -> acc ++ chunk end)},
           %Chromosome{p2 | genes: Enum.reduce(chunks_p2, [], fn chunk, acc -> acc ++ chunk end)}}

        # IO.gets("p1: #{inspect(p1)}, p2: #{inspect(p2)}\nc1: #{inspect(c1)}, c2: #{inspect(c2)}\nPress enter to continue" )

        [c1, c2 | acc]
      end
    )
  end

  def custom_mutation(population, opts \\ []) do
    # Logger.info("Custom mutation with population: #{inspect(population)} and opts: #{inspect(opts)}")

    fix_start = Keyword.get(opts, :fix_start, -1)
    fix_end = Keyword.get(opts, :fix_end, -1)
    mutation(population, fix_start, fix_end, opts)
  end

  defp mutation(population, -1, -1, opts) do
    Mutation.mutation_shuffle(population, opts)
  end

  defp mutation(population, fix_start, fix_end, opts) do
    deny_numbers = [fix_start, fix_end]
    mutation_probability = Keyword.get(opts, :mutation_probability, 0.05)

    population
    |> Enum.map(fn chromosome ->
      if :rand.uniform() < mutation_probability * 1000 do
        random_element_1 = Utils.random_allow_number(deny_numbers, opts)
        random_element_2 = Utils.random_allow_number(deny_numbers ++ [random_element_1], opts)

        %Chromosome{
          chromosome
          | genes: Utils.swap(chromosome.genes, random_element_1, random_element_2)
        }
      else
        chromosome
      end
    end)
  end
end
