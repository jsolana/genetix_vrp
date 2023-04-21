defmodule GenetixVrp.VehicleRoutingProblem do
  @moduledoc """
  A specific problem implementation for Vehicle Routing Problem (VRP). Following the instructions of `Genetix.Problem`  we need to provide a definition of:
  - How to generate a genotype / chromosome: `genotype` function.
  - How to score a chromosome: `fitnes_score` function.
  - How to determine if the algorithm ends or not: `terminate` function.

  Additionally we also define custom operators as `crossover_custom` and `mutation_custom` to override these operators in the `Genetix` algorithm.

  Custom mandatory hyperparameters:

  - `crossover_type`:       Crossover operator. By defaul `crossover_cx_one_point/3`. To run successfully this problem, you need to override this property using `custom_crossover` function.
  - `mutation_type`:        Mutation operator. By default `mutation_shuffle/2`. To run successfully this problem, you need to override this property using `custom_mutation` function.
  - `sort_criteria`:        How to sort the population by its fitness score (max or min). By default min first.
  - `matrix`:               `GenetixVrp.Types.DistanceDurationMatrix` data for the locations provided.

  Optional hyperparameters:

  - `fix_start`:            If all vehicles must start in a specific location. By default `-1` (no fix_start).
  - `fix_end`:              If all vehicles must ends in a specific location. By default `-1` (no fix_start).
  - `size`:                 Total number of locations. By default `10`.
  - `population_size`:      Total number of individuals to run the algorithm. By default `100`.
  - `vehicle_capacity`:     Number of riders / stops the vehicle can handle. By default `4`.
  - `max_generation`:       Termination criteria. The max number of genertion to  generate the optimal routes. By defaul `10_000`.


  For matrix providers:
  - `speed_in_meters`:      To calculate the duration matrix for `GreatCircleDistance` provider. By default `50_000`.
  -  `matrix_profile`:      Used for `OpenRouteServiceClient` provider to calculate the distante_duration matrix. By defaul `driving-car`.

  You can check [here](lib/genetix_vrp/matrix/adapter/adapter.ex) to know the current available providers.

  To generate an individual chromosome:

      iex> alias GenetixVrp.VehicleRoutingProblem, as: VRP
      iex> individual = VRP.genotype(size: 10, fix_start: 0)

  To generate a population of chromosomes:

      iex> alias GenetixVrp.VehicleRoutingProblem, as: VRP
      iex> population_size = 10
      iex> population = for _ <- 1..population_size, do: VRP.genotype(size: 10, fix_start: 0)
      iex> population = 1..population_size |> Enum.map(fn _index ->  VRP.genotype(size: 10, fix_start: 0) end)

  Depending of the hyperparameters, it is possible to define different kind of routes:

    - A `go_home` route(s): The same start point (`fix_start`) and differents end points per vehicle:

    ```elixir
      GenetixVrp.VehicleRoutingProblem.genotype(size: 10, fix_start: 6)
      %Genetix.Types.Chromosome{
        genes: [6, 9, 1, 5, 6, 4, 0, 2, 6, 7, 8, 3, 6, 10],
        size: 10,
        fitness: 0,
        age: 0
      }
    ```

    - A `go_office` route(s): The same end point (`fix_end`) and differents start point per vehicle:

    ```elixir
      GenetixVrp.VehicleRoutingProblem.genotype(size: 10, fix_end: 6)
      %Genetix.Types.Chromosome{
        genes: [7, 9, 8, 1, 6, 3, 0, 2, 4, 6, 5, 6],
        size: 10,
        fitness: 0,
        age: 0
      }
    ```

    *Note*: Other kind of trips as `go_trip` (with an  commont start and end location per vehicle) or `go_random` (no location in common between vehicles) are not implemented yet.

  """
  @behaviour Genetix.Problem
  alias Genetix.Types.Chromosome
  # alias Genetix.Mutation
  alias GenetixVrp.Utils

  require Logger

  @doc """
  VRP encoding as a permutation with a little custmo characteristics.
  We use a list of  numbers to represent the list of locations ORDERED.
  Because the idea is to solve N stops with M vehicles, each vehicle has a capacity defined by `vehicle_capacity` hyperparameter.

  It is also possible to define different kinds of routes:
      - go_home: A common start and different ends.
      - go_office:  Different starts and a common end.
      - go_random: Not related with the others. (TODO)
      - go_trip: A common start / end. (TODO)
  We can fix the start, end of all the routes with `fix_start` and `fix_end` hyperparameters.
  ## Examples (for all, the vehicle_capacity is 4)

    # go_home:
      All locations: [0, 1, 2, 3, 4, 5, 6, 7, 8]
      fix_start: 0. It means that the location with value 0 is the start for all the vehicles.
        - vehicle_1: [0, 1, 2, 3, 4]. The vehicle start at 0  and pickup all the riders (and must to stop on 1, 2, 3, 4)
        - vehicle_2: [0, 5, 6, 7, 8]

      For this case, a possible genotype that represents this situation (genes) could be: [0, 1, 2, 3, 4, 0, 5, 6, 7, 8] (but also [0, 7, 5, 4, 3, 0, 8, 1, 2, 6])

    # go_office:
    All locations: [0, 1, 2, 3, 4, 5, 6, 7, 8]
    fix_end: 0. It means that the location with value 0 is the end for all the vehicles.
      - vehicle_1: [1, 2, 3, 4, 0]. The vehicle start at 1, continue to 2, 3..  and drop off all the riders at 0.
      - vehicle_2: [5, 6, 7, 8, 0]

    For this case, a possible genotype that represents this situation (genes) could be: [1, 2, 3, 4, 0, 5, 6, 7, 8, 0] (but also [7, 5, 4, 3, 0, 8, 1, 2, 6, 0])

    # go_trip (TODO):
      All locations: [0, 1, 2, 3, 4, 5, 6, 7, 8]
      fix_start: 0, fix_end: 6. It means that the location with value 0 is the start for all the vehicles and 6 the end of all of them.
        - vehicle_1: [0, 1, 2, 3, 6]. The vehicle start at 0  and pickup all the riders (and must to stop on 1, 2, 3, 4)
        - vehicle_2: [0, 5, 4, 7, 6]

      For this case, a possible genotype that represents this situation (genes) could be: [0, 1, 2, 3, 6, 0, 5, 4, 7, 8, 6]

    # go_random (TODO):
      All locations: [0, 1, 2, 3, 4, 5, 6, 7, 8]
        - vehicle_1: [0, 1, 2, 3]
        - vehicle_2: [4, 5, 6, 7]
        - vehicle_3: [8]
      For this case, a possible genotype that represents this situation (genes) could be: [0, 1, 2, 3, 4, 5, 6, 7, 8] (but also [0, 2, 3, 4, 7, 1, 5, 8, 6]).
      This case is weird because assume that the pickup is already done??


  """
  @impl true
  def genotype(opts \\ []) do
    fix_start = Keyword.get(opts, :fix_start, -1)
    fix_end = Keyword.get(opts, :fix_end, -1)
    size = Keyword.get(opts, :size, 10)
    vehicle_capacity = Keyword.get(opts, :vehicle_capacity, 4)
    %Chromosome{genes: create_genes(fix_start, fix_end, size, vehicle_capacity), size: size}
  end

  # go_random
  # defp create_genes(-1, -1, size, _vehicle_capacity) do
  #  Enum.shuffle(for index <- 0..(size - 1), do: index)
  # end

  # go_office
  defp create_genes(-1, fix_end, size, vehicle_capacity)
       when is_integer(fix_end) and fix_end >= 0 and fix_end < size do
    Enum.shuffle(for(index <- 0..(size - 1), do: index))
    |> Enum.filter(fn x -> x != fix_end end)
    |> Enum.chunk_every(vehicle_capacity)
    |> Enum.map(fn sublist -> sublist ++ [fix_end] end)
    |> List.flatten()
  end

  # go_home
  defp create_genes(fix_start, -1, size, vehicle_capacity)
       when is_integer(fix_start) and fix_start >= 0 and fix_start < size do
    Enum.shuffle(for(index <- 0..(size - 1), do: index))
    |> Enum.filter(fn x -> x != fix_start end)
    |> Enum.chunk_every(vehicle_capacity)
    |> Enum.map(fn sublist -> [fix_start] ++ sublist end)
    |> List.flatten()
  end

  # go_trip
  # defp create_genes(fix_start, fix_end, size, vehicle_capacity)
  #     when is_integer(fix_start) and fix_start >= 0 and fix_start < size and
  #            is_integer(fix_end) and fix_end >= 0 and fix_end < size and fix_start != fix_end do
  #  Enum.shuffle(for(index <- 0..(size - 1), do: index))
  #  |> Enum.filter(fn x -> x != fix_start and x != fix_end end)
  #  |> Enum.chunk_every(vehicle_capacity - 1)
  #  |> Enum.map(fn sublist -> [fix_start] ++ sublist ++ [fix_end] end)
  #  |> List.flatten()
  # end

  @impl true
  def fitness_function(chromosome, opts \\ []) do
    fix_start = Keyword.get(opts, :fix_start, -1)
    fix_end = Keyword.get(opts, :fix_end, -1)

    vehicle_capacity =
      get_vehicle_capacity(fix_start, fix_end, Keyword.get(opts, :vehicle_capacity, 4))

    if chromosome_is_valid(chromosome, fix_start, fix_end, vehicle_capacity) do
      matrix = Keyword.get(opts, :matrix)

      pairs =
        chromosome.genes
        |> Enum.chunk_every(vehicle_capacity)
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

      # IO.gets("Calculating fitness function for route #{inspect(chromosome.genes)}\nRoutes: #{inspect(pairs)}\nresult: #{inspect(result)}\nPress enter to continue...")

      result
    else
      # max integer (Penalty function if the chromosome is not valid)
      :math.pow(2, 63) - 1
    end
  end

  # For go_random
  # defp chromosome_is_valid(_chromosome, -1, -1, _vehicle_capacity), do: true

  # For go_home
  defp chromosome_is_valid(chromosome, fix_start, -1, vehicle_capacity) do
    chromosome.genes
    |> Enum.chunk_every(vehicle_capacity)
    |> Enum.all?(&(List.first(&1) == fix_start))
  end

  # For go_office
  defp chromosome_is_valid(chromosome, -1, fix_end, vehicle_capacity) do
    chromosome.genes
    |> Enum.chunk_every(vehicle_capacity)
    |> Enum.all?(&(List.last(&1) == fix_end))
  end

  # For go_trip
  # defp chromosome_is_valid(chromosome, fix_start, fix_end, vehicle_capacity) do
  #  chromosome.genes
  #  |> Enum.chunk_every(vehicle_capacity)
  #  |> Enum.all?(&(List.last(&1) == fix_end and List.first(&1) == fix_start))
  # end

  # For go_random
  # defp get_vehicle_capacity(-1, -1, vehicle_capacity), do: vehicle_capacity

  # For the other kind of routes: go_home, go_office (we have one more that represent the common pickup / drop-off)
  defp get_vehicle_capacity(_fix_start, _fix_end, vehicle_capacity), do: vehicle_capacity + 1

  @impl true
  def terminate?([best | _], generation, opts \\ []) do
    max_generation = Keyword.get(opts, :max_generation, 10_000)
    IO.write("\r#{best.fitness}")
    generation == max_generation
  end

  @doc """
  Order-one crossover customized for the specific encoding of the problem.

  It works like this:

    1) Remove fix_start / fix_end (if exists)
    2) Select a random slice of genes from Parent 1.
    4) Remove the values from the slice of Parent 1 from Parent 2.
    4) Insert the slice from Parten 1 into the same position in Parent 2.
    5) Insert fix_start / fix_end
    6) Repeat with a random slice from Parten 2.

  """
  def custom_crossover(parent_1, parent_2, opts \\ []) do
    # Logger.info("Custom crossover with population: #{inspect(population)} and opts: #{inspect(opts)}")
    fix_start = Keyword.get(opts, :fix_start, -1)
    fix_end = Keyword.get(opts, :fix_end, -1)
    vehicle_capacity = Keyword.get(opts, :vehicle_capacity, 4)

    clean_parent_1_genes =
      parent_1.genes |> Enum.reject(fn x -> x == fix_start or x == fix_end end)

    clean_parent_2_genes =
      parent_2.genes |> Enum.reject(fn x -> x == fix_start or x == fix_end end)

    lim = Enum.count(clean_parent_1_genes) - 1
    {i1, i2} = [:rand.uniform(lim), :rand.uniform(lim)] |> Enum.sort() |> List.to_tuple()

    # parent_2 contribution​
    slice1 = Enum.slice(clean_parent_1_genes, i1..i2)
    slice1_set = MapSet.new(slice1)
    parent_2_contrib = Enum.reject(clean_parent_2_genes, &MapSet.member?(slice1_set, &1))
    {head1, tail1} = Enum.split(parent_2_contrib, i1)

    # clean_parent_1_genes contribution​
    slice2 = Enum.slice(clean_parent_2_genes, i1..i2)
    slice2_set = MapSet.new(slice2)
    parent_1_contrib = Enum.reject(clean_parent_1_genes, &MapSet.member?(slice2_set, &1))
    {head2, tail2} = Enum.split(parent_1_contrib, i1)

    # Make and return​
    {c1, c2} = {head1 ++ slice1 ++ tail1, head2 ++ slice2 ++ tail2}

    {%Chromosome{parent_1 | genes: add_fixed_locations(c1, fix_start, fix_end, vehicle_capacity)},
     %Chromosome{parent_2 | genes: add_fixed_locations(c2, fix_start, fix_end, vehicle_capacity)}}
  end

  # go_random
  # defp add_fixed_locations(genes, -1, -1, _vehicle_capacity) do
  #  genes
  # end

  # go_office
  defp add_fixed_locations(genes, -1, fix_end, vehicle_capacity)
       when is_integer(fix_end) and fix_end >= 0 do
    genes
    |> Enum.chunk_every(vehicle_capacity)
    |> Enum.map(fn sublist -> sublist ++ [fix_end] end)
    |> List.flatten()
  end

  # go_home
  defp add_fixed_locations(genes, fix_start, -1, vehicle_capacity)
       when is_integer(fix_start) and fix_start >= 0 do
    genes
    |> Enum.chunk_every(vehicle_capacity)
    |> Enum.map(fn sublist -> [fix_start] ++ sublist end)
    |> List.flatten()
  end

  # go_trip
  # defp add_fixed_locations(genes, fix_start, fix_end, vehicle_capacity)
  #     when is_integer(fix_start) and fix_start >= 0 and
  #            is_integer(fix_end) and fix_end >= 0 and fix_start != fix_end do
  #  genes
  #  |> Enum.chunk_every(vehicle_capacity - 1)
  #  |> Enum.map(fn sublist -> [fix_start] ++ sublist ++ [fix_end] end)
  #  |> List.flatten()
  # end

  @doc """
  Swap two locations of the chromosome.
  """
  def custom_mutation(chromosome, opts \\ []) do
    # Logger.info("Custom mutation of the chromosome: #{inspect(chromosome)} with opts: #{inspect(opts)}")
    fix_start = Keyword.get(opts, :fix_start, -1)
    fix_end = Keyword.get(opts, :fix_end, -1)
    deny_numbers = [fix_start, fix_end]
    random_stop_1 = Utils.random_allow_number(deny_numbers, opts)
    random_stop_2 = Utils.random_allow_number(deny_numbers ++ [random_stop_1], opts)

    %Chromosome{
      chromosome
      | genes: Utils.swap(chromosome.genes, random_stop_1, random_stop_2)
    }
  end
end
