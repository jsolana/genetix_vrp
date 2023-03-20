defmodule GeneticVrp.Types.Location do
  @moduledoc """
  Location type definition. A location is defined by its latitud and longitude. Both are mandantory.
  An example of `Location`:

  ```elixir
    %GeneticVrp.Types.Location{latitude: 40.24, longitude: 3.42}
  ```

  """
  @type t :: %__MODULE__{
          latitude: number(),
          longitude: number()
        }

  @enforce_keys [:latitude, :longitude]
  defstruct latitude: 0, longitude: 0
end
