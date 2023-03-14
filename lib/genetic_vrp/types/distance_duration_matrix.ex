defmodule GeneticVrp.Types.DistanceDurationMatrix do
  @moduledoc """
  Distance duration matrix type definition
  """
  @type t :: %__MODULE__{
          locations: list(),
          matrix: map()
        }

  @enforce_keys [:locations, :matrix]
  defstruct locations: [], matrix: %{}
end
