defmodule GeneticVrp.Matrix.Adapter do
  @moduledoc """
  Behaviour for calculate distance duration matrix.
  Distance will be provided in meters.
  Duration will be provided in seconds.

  An example of result calling `get_distance_duration_matrix/2`:

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
  alias GeneticVrp.Types.{DistanceDurationMatrix, Location}

  @doc """
  Returns a matrix of distance / duration related of the locations provided:
    - Distance in meters.
    - Duration in seconds.
  """
  @callback get_distance_duration_matrix(locations :: [Location.t()], keyword()) ::
              {:ok, DistanceDurationMatrix.t()}
              | {:error, integer()}
end
