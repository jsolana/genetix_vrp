defmodule GeneticVrp.Matrix.Adapter.GreatCircleDistance do
  @moduledoc """
  Distance duration matrix implementation using a Great circle distance implementation.
  The great-circle distance, orthodromic distance, or spherical distance is the distance along a great circle.

  The Great cicle distance is the shortest distance between two points on the surface of a sphere, measured along the surface
  of the sphere (as opposed to a straight line through the sphere's interior).
  The distance between two points in Euclidean space is the length of a straight line between them,
  but on the sphere there are no straight lines. In spaces with curvature, straight lines are replaced by geodesics.
  Geodesics on the sphere are circles on the sphere whose centers coincide with the center of the sphere, and are called
  `great circles`.

  The distance is provided in meters appying Harvesine formula.
  The duration is provided in seconds from the distance using `speed_in_meters` hyperparamter.

  Note: Take in count this is a naive approach to calculate the distance / duration of a specific list of locations.
  A lot of aspects are ommitted as traffic conditions, etc.

  ## Examples

  iex> alias GeneticVrp.Matrix.Adapter.GreatCircleDistance, as: MatrixProvider
  iex> locations = [[9.7, 48.4],[9.2,49.1],[10.1, 50.1], [20.1,60.1]]
    iex> {:ok, matrix} = MatrixProvider.get_distance_duration_matrix(locations)
    iex> true = (matrix.locations == locations)

  """

  @behaviour GeneticVrp.Matrix.Adapter

  alias GeneticVrp.Types.Location
  alias GeneticVrp.Utils
  require Logger

  @impl true
  def get_distance_duration_matrix(locations, opts \\ []) do
    # Logger.info(inspect(locations))
    distances = get_distances(locations, opts)
    durations = get_durations(locations, opts)

    matrix = %GeneticVrp.Types.DistanceDurationMatrix{
      locations: locations,
      matrix:
        Enum.reduce(distances, %{}, fn {key, _value}, acc ->
          Map.put(acc, key, {distances[key], durations[key]})
        end)
    }

    {:ok, matrix}
  end

  defp get_distances(locations, _opts) do
    locations
    |> Enum.map(fn [lat1, long1] ->
      Enum.map(locations, fn [lat2, long2] ->
        GeneticVrp.Matrix.Adapter.GreatCircleDistance.get_great_circle_distance(
          %GeneticVrp.Types.Location{latitude: lat1, longitude: long1},
          %GeneticVrp.Types.Location{latitude: lat2, longitude: long2}
        )
      end)
    end)
    |> Utils.list_of_lists_to_map()
  end

  defp get_durations(locations, _opts) do
    locations
    |> Enum.map(fn [lat1, long1] ->
      Enum.map(locations, fn [lat2, long2] ->
        GeneticVrp.Matrix.Adapter.GreatCircleDistance.get_duration_from_location(
          %GeneticVrp.Types.Location{latitude: lat1, longitude: long1},
          %GeneticVrp.Types.Location{latitude: lat2, longitude: long2}
        )
      end)
    end)
    |> Utils.list_of_lists_to_map()
  end

  def get_great_circle_distance(%Location{latitude: lat1, longitude: lon1}, %Location{
        latitude: lat2,
        longitude: lon2
      }) do
    # Earth's radius in kilometers
    radius = 6371
    dlat = deg_to_rad(lat2 - lat1)
    dlon = deg_to_rad(lon2 - lon1)

    a =
      :math.sin(dlat / 2) * :math.sin(dlat / 2) +
        :math.cos(deg_to_rad(lat1)) * :math.cos(deg_to_rad(lat2)) *
          :math.sin(dlon / 2) * :math.sin(dlon / 2)

    c = 2 * :math.atan2(:math.sqrt(a), :math.sqrt(1 - a))
    round(radius * c * 1000)
  end

  defp deg_to_rad(deg) do
    deg * :math.pi() / 180
  end

  def get_duration_from_location(%Location{} = location1, %Location{} = location2, opts \\ []) do
    distance_meters = get_great_circle_distance(location1, location2)
    get_duration_from_distance(distance_meters, opts)
  end

  def get_duration_from_distance(distance_meters, opts \\ []) do
    speed_meters = Keyword.get(opts, :speed_in_meters, 50_000)
    round(3600 * distance_meters / speed_meters)
  end
end
