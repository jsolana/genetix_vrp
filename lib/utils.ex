defmodule GeneticVrp.Utils do
  @moduledoc false

  @doc """
  Generate a map {x,y} => item from a list of lists.
  Returns: `map()`.

  ## Examples

    iex> list_of_lists = [[0,1,2],[3,4,5], [6,7,8]]
    iex> %{{0, 0} => 0,{0, 1} => 1, {0, 2} => 2, {1, 0} => 3,
    ...> {1, 1} => 4, {1, 2} => 5, {2, 0} => 6, {2, 1} => 7, {2, 2} => 8 } = GeneticVrp.Utils.list_of_lists_to_map(list_of_lists)

  """
  def list_of_lists_to_map(list_of_lists) do
    Enum.reduce(list_of_lists, %{}, fn list, acc ->
      Enum.reduce(list, acc, fn item, inner_acc ->
        x = Enum.find_index(list_of_lists, fn l -> l == list end)
        y = list |> Enum.find_index(&(&1 == item))
        Map.put(inner_acc, {x, y}, item)
      end)
    end)
  end
end
