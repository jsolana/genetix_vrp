defmodule GeneticVrp.Types.Location do
  @moduledoc """
  Location type definition
  """
  @type t :: %__MODULE__{
          latitude: number(),
          longitude: number()
        }

  @enforce_keys [:latitude, :longitude]
  defstruct latitude: 0, longitude: 0
end
