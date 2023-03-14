defmodule GeneticVrp.Matrix.Adapter do
  @moduledoc """
  Behaviour for calculate duration distance matrix
  """
  alias GeneticVrp.Types.{DistanceDurationMatrix, Location}

  @doc """
  Return a matrix of duration in seconds and distances in meters related of the locations provided
  """
  @callback get_distance_duration_matrix(locations :: [Location.t()], keyword()) ::
              {:ok, DistanceDurationMatrix.t()}
              | {:error, integer()}
end
