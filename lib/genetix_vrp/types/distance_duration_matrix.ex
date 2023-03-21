defmodule GenetixVrp.Types.DistanceDurationMatrix do
  @moduledoc """
  Distance duration matrix type definition. Both properties (location and matrix) are mandatory.
  An example of `DistanceDurationMatrix`:

  ```elixir
    %GenetixVrp.Types.DistanceDurationMatrix{
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
    }
  ```
  """
  @typedoc """
  DistanceDurationMatrix type.

  DistanceDurationMatrix are represented as a `%DistanceDurationMatrix{}`.
  At a minimum a DistanceDurationMatrix needs `:locations` and `matrix`.

  # Fields

    - `:locations`: `Enum` containing the locations.
    - `:matrix`: `Map` with the distance / duration between each location in meters and seconds respectively.
  """
  @type t :: %__MODULE__{
          locations: list(),
          matrix: map()
        }

  @enforce_keys [:locations, :matrix]
  defstruct locations: [], matrix: %{}
end
