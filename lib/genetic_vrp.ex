defmodule GeneticVrp do
  @moduledoc """
  This module define the methods to invoke genetic algorithms to solve VRP
  To run a Problem you only need to:

  alias GeneticVrp.VehicleRouting
  alias Genetics.Evolution
  opts = []
  Evolution.run(VehicleRouting, opts )

  Genetics.Evolution.run(GeneticVrp.VehicleRouting, opts)

  To obtain the matrix:

  locations = [[9.7, 48.4],[9.2,49.1],[10.1, 50.1], [20.1,60.1]]
  {:ok, matrix} = GeneticVrp.get_matrix(locations)

  {:ok,
  %GeneticVrp.Types.DistanceDurationMatrix{
   locations: [[9.7, 48.4], [9.2, 49.1], [10.1, 50.1], [20.1, 60.1]],
   matrix: %{
     {0, 0} => {0.0, 0.0},
     {0, 1} => {145722.03, 6552.6},
     {0, 2} => {273238.0, 9483.85},
     {0, 3} => {1875021.75, 116402.3},
     {1, 0} => {146857.2, 6336.95},
     {1, 1} => {0.0, 0.0},
     {1, 2} => {176026.67, 6729.5},
     {1, 3} => {1777810.5, 113647.95},
     {2, 0} => {270151.53, 9657.62},
     {2, 1} => {172690.25, 6781.27},
     {2, 2} => {0.0, 0.0},
     {2, 3} => {1621698.75, 109354.7},
     {3, 0} => {1965809.5, 79862.18},
     {3, 1} => {1868348.25, 76985.84},
     {3, 2} => {1713152.63, 72741.59},
     {3, 3} => {0.0, 0.0}
   }
  }}

  locations = [[9.7, 48.4],[9.2,49.1],[10.1, 50.1], [20.1,60.1], [19.7, 48.4],[19.2,49.1],[11.1, 50.1], [27.1,60.1]]
  GeneticVrp.calculate_routes(locations, fix_start: 0, max_generation: 2, population_size: 5000)

  """

  # @adapter GeneticVrp.Matrix.Adapter.OpenRouteServiceClient
  # alias GeneticVrp.Matrix.Adapter.OpenRouteServiceClient, as: Adapter
  alias GeneticVrp.Matrix.Adapter.GreatCircleDistance, as: Adapter
  alias Genetics.Evolution
  alias GeneticVrp.VehicleRouting
  require Logger

  def calculate_routes(locations, opts \\ []) do
    case get_matrix(locations, opts) do
      {:ok, matrix} ->
        # Logger.info("Matrix: #{inspect(matrix)}")
        soln =
          Evolution.run(
            VehicleRouting,
            opts ++
              [
                matrix: matrix,
                size: length(locations),
                crossover_type: &VehicleRouting.custom_crossover/2,
                mutation_type: &VehicleRouting.custom_mutation/2,
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

  def get_matrix(locations, opts \\ []) do
    case Adapter.get_distance_duration_matrix(locations, opts) do
      {:ok, matrix} ->
        {:ok, matrix}

      {:error, status} ->
        {:error, status}
    end
  end
end
