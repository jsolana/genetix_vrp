defmodule GenetixVrp.Utils do
  @moduledoc false

  @doc """
  Generate a map {x,y} => item from a list of lists.
  Returns: `map()`.

  ## Examples

    iex> list_of_lists = [[0,1,2],[3,4,5], [6,7,8]]
    iex> %{{0, 0} => 0,{0, 1} => 1, {0, 2} => 2, {1, 0} => 3,
    ...> {1, 1} => 4, {1, 2} => 5, {2, 0} => 6, {2, 1} => 7, {2, 2} => 8 } = GenetixVrp.Utils.list_of_lists_to_map(list_of_lists)

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

  @doc """
  Generate a random number avoiding specific deny numbers
  Returns: `number()`.
  It is possible to replace by take_random()

  ## Examples

    iex> deny_numbers = [0,1,2,3,4,5,6,7,8]
    iex> 9 = GenetixVrp.Utils.random_allow_number(deny_numbers)

    iex> deny_numbers = [1]
    iex> 1 != GenetixVrp.Utils.random_allow_number(deny_numbers)
  """
  def random_allow_number(deny_numbers, opts \\ []) do
    size = Keyword.get(opts, :size, 10)

    Enum.shuffle(for(index <- 0..(size - 1), do: index))
    |> Enum.filter(fn x -> !Enum.member?(deny_numbers, x) end)
    |> Enum.random()
  end

  @doc """
  Swap two elements of a list
  Returns: `list()`.

  ## Examples

    iex> list = [0,1,2,3,4,5,6,7,8]
    iex> [8, 1, 2, 3, 4, 5, 6, 7, 0] = GenetixVrp.Utils.swap(list, 0, 8)

    iex> list = [0,1,2,3,4,5,6,7,8]
    iex> [1, 0, 3, 2, 4, 5, 6, 7, 8] = GenetixVrp.Utils.swap(list, 0, 1) |> GenetixVrp.Utils.swap(2, 3)

  """
  def swap(list, position_1, position_2) do
    element_1 = Enum.at(list, position_1)
    element_2 = Enum.at(list, position_2)

    list
    |> List.replace_at(position_1, element_2)
    |> List.replace_at(position_2, element_1)
  end
end
