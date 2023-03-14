defmodule GeneticVrp.Matrix.Adapter.GreatCircleDistance do
  @moduledoc """
  Distance duration matrix implementation using a Great circle distance implementation
  Distance in meters appying Harvesine formula

  ## Example

    iex> locations = [[9.7, 48.4],[9.2,49.1],[10.1, 50.1], [20.1,60.1]]
    iex> {:ok, matrix} = GeneticVrp.Matrix.Adapter.GreatCircleDistance.get_distance_duration_matrix(locations)

  Calling get_distance_duration_matrix(locations) retrieves a `GeneticVrp.Types.DistanceDurationMatrix` with the distance /duration matrix

  ```elixir
      {:ok,
      %GeneticVrp.Types.DistanceDurationMatrix{
      locations: [[9.7, 48.4], [9.2, 49.1], [10.1, 50.1], [20.1, 60.1]],
      matrix: %{
        {0, 0} => {0, 0},
        {0, 1} => {94796, 6825},
        {0, 2} => {191454, 13785},
        {0, 3} => {1706556, 122872},
        {1, 0} => {94796, 6825},
        {1, 1} => {0, 0},
        {1, 2} => {148431, 10687},
        {1, 3} => {1692340, 121848},
        {2, 0} => {191454, 13785},
        {2, 1} => {148431, 10687},
        {2, 2} => {0, 0},
        {2, 3} => {1544405, 111197},
        {3, 0} => {1706556, 122872},
        {3, 1} => {1692340, 121848},
        {3, 2} => {1544405, 111197},
        {3, 3} => {0, 0}
      }
      }}
  ```
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
