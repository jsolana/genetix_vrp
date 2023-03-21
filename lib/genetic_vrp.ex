defmodule GeneticVrp do
  @moduledoc """
  This module define the functions to solve Vehicle Routing Problems (AKA `VRP`) using genetic algorithms (using `Genetics`).
  The vehicle routing problem (VRP) is a combinatorial optimization and integer programming problem which asks
  "What is the optimal set of routes for a fleet of vehicles to traverse in order to deliver to a given set of customers?"
  It generalises the travelling salesman problem (TSP).

  To run the algorithm you only need to call `calculate_routes/2` function providing the list of locations and the hyperparameters required.

  This module internally customize the `VehicleRoutingProblem` with custom hyperparameters as:

  Common hyperparameters:

  - `crossover_type`: Crossover operator. By defaul `crossover_cx_one_point/3`. To run successfully this problem, you need to override this property using `custom_crossover` function.
  - `mutation_type`: Mutation operator. By default `mutation_shuffle/2`. To run successfully this problem, you need to override this property using `custom_mutation` function.

  Mandatory hyperparameters:

  - `matrix`: `GeneticVrp.Types.DistanceDurationMatrix` data for the locations provided.


  For more information about the hyperparameters that the problem accept, check the documentation of `GeneticVrp.VehicleRoutingProblem`.

  When call `calculate_routes/2` internally:

  1) Get the distance / duration matrix
  2) Set specific hyperparameters as:
    - `crossover_type` operator
    - `mutation_type` opertor
    - `matrix`
    - `size` using `length(locations)`
    - `sort_criteria` ordering the populations by fitness score, minimal first (`&<=2`).
    - `population_size` using `size`* 100

  ## Examples

      iex> locations = [[9.7, 48.4],[9.2,49.1],[10.1, 50.1], [20.1,60.1], [19.7, 48.4],[19.2,49.1],[11.1, 50.1], [21.1,60.1]]
      iex> GeneticVrp.calculate_routes(locations, fix_start: 0, max_generation: 10, population_size: 100)

      # To run the `VehicleRoutingProblem` you can use directly the `Genetics.Evolution` with the options required

      iex> alias GeneticVrp.VehicleRoutingProblem
      iex> alias Genetics.Evolution
      iex> locations = [[9.7, 48.4],[9.2,49.1],[10.1, 50.1], [20.1,60.1], [19.7, 48.4],[19.2,49.1],[11.1, 50.1], [21.1,60.1]]
      iex> {:ok, matrix} = GeneticVrp.get_matrix(locations)
      iex> opts = [matrix: matrix, max_generation: 1, fix_start: 0]
      iex> Evolution.run(VehicleRoutingProblem, opts )

  """

  # @adapter GeneticVrp.Matrix.Adapter.OpenRouteServiceClient
  # alias GeneticVrp.Matrix.Adapter.OpenRouteServiceClient, as: Adapter
  alias GeneticVrp.Matrix.Adapter.GreatCircleDistance, as: Adapter
  alias Genetics.Evolution
  alias GeneticVrp.VehicleRoutingProblem
  require Logger

  @doc """
  Calculate routes optimized using genetic algorithms.

  When call `calculate_routes/2` internally:

  1) Get the distance / duration matrix
  2) Set specific hyperparameters as:
    - `crossover_type` operator
    - `mutation_type` opertor
    - `matrix`
    - `size` using `length(locations)`
    - `sort_criteria` ordering the populations by fitness score, minimal first (`&<=2`).
    - `population_size` using `size`* 100
  """
  def calculate_routes(locations, opts \\ []) do
    case get_matrix(locations, opts) do
      {:ok, matrix} ->
        soln =
          Evolution.run(
            VehicleRoutingProblem,
            opts ++
              [
                matrix: matrix,
                size: length(locations),
                crossover_type: &VehicleRoutingProblem.custom_crossover/3,
                mutation_type: &VehicleRoutingProblem.custom_mutation/2,
                sort_criteria: &<=/2,
                population_size: length(locations) * 100
              ]
          )

        Logger.info("Solution: #{inspect(soln)}")
        {:ok, soln.genes}

      {:error, status} ->
        {:error, status}
    end
  end

  @doc """
  Retrieves the distance / duration matrix in meters / seconds for the locations list provided.
  """
  def get_matrix(locations, opts \\ []) do
    case Adapter.get_distance_duration_matrix(locations, opts) do
      {:ok, matrix} ->
        {:ok, matrix}

      {:error, status} ->
        {:error, status}
    end
  end
end
