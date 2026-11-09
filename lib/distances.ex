defmodule Distances do
  @moduledoc """
  Represents maze cell distances from a starting maze cell calculated using
  Dijkstra’s algorithm.

  ## Fields
    - `root_coord`: Coordinates for the root maze cell from which distances are
    measured.
    - `cell_distances`: A map of maps representing the distances from the root
    cell to each cell in the maze.
  """
  @type t :: %__MODULE__{
          root_coord: Coordinate.t(),
          cell_distances: %{non_neg_integer() => %{non_neg_integer() => non_neg_integer()}}
        }
  @enforce_keys [:root_coord]
  defstruct [:root_coord, cell_distances: %{}]

  @doc """
  Calculates the distances from the root cell to all other cells in the maze
  using Dijkstra's algorithm.

  ## Parameters
    - maze: The maze for which to calculate distances.
    - root_cell_row: The row of the root cell.
    - root_cell_col: The column of the root cell.

  Returns a `Distances` struct.
  """
  def calculate(%Grid{} = maze, root_cell_row, root_cell_col)
      when is_integer(root_cell_row) and is_integer(root_cell_col) and root_cell_row > 0 and
             root_cell_col > 0 do
    root_coord = %Coordinate{row: root_cell_row, col: root_cell_col}
    calculate(maze, root_coord)
  end

  @doc """
  Calculates the distances from the root cell to all other cells in the maze
  using Dijkstra's algorithm.

  ## Parameters
    - maze: The maze for which to calculate distances.
    - root_cell_coord: The coordinates of the root cell.

  Returns a `Distances` struct.
  """
  def calculate(%Grid{} = maze, %Coordinate{} = root_cell_coord) do
    cell_dist_matrix = initialize_matrix(maze.num_rows, maze.num_cols)

    %__MODULE__{
      root_coord: root_cell_coord,
      cell_distances: calc_cell_distances(cell_dist_matrix, maze, root_cell_coord)
    }
  end

  @doc """
  Gets the distance from the root cell to the given cell.
  """
  def get_cell_distance(%__MODULE__{} = distances, %Cell{} = cell),
    do: get_distance(distances.cell_distances, cell.coord)

  def get_cell_distance(%__MODULE__{} = distances, %Coordinate{} = coord),
    do: get_distance(distances.cell_distances, coord)

  # ==========================
  # Internal Functions
  # ==========================

  # Get the distance value for a specific cell in the matrix
  defp get_distance(%{} = dist, %Coordinate{row: row, col: col}) do
    case Map.get(dist, row) do
      nil -> nil
      row_map -> Map.get(row_map, col)
    end
  end

  # Set the distance value for a specific cell in the matrix
  defp set_distance(%{} = distance_matrix, %Coordinate{} = matrix_coord, distance) do
    put_in(distance_matrix[matrix_coord.row][matrix_coord.col], distance)
  end

  # Set the distance values for a list of cells in the matrix
  defp set_distance(%{} = distance_matrix, [], _value) do
    distance_matrix
  end

  defp set_distance(%{} = distance_matrix, for_cell_coords, distance) do
    Enum.reduce(for_cell_coords, distance_matrix, fn coord, acc_matrix ->
      set_distance(acc_matrix, coord, distance)
    end)
  end

  # Filter out coordinates that already have a distance value in the matrix
  defp filter_unset_coords(coord_list, %{} = distance_matrix) do
    coord_list |> Enum.filter(&(get_cell_distance(distance_matrix, &1) == nil))
  end

  # Find the coordinates of all cells linked to the given list of cell coordinates
  defp find_links(%Grid{} = maze, for_cell_coords) do
    Enum.flat_map(for_cell_coords, fn coord ->
      Grid.get_cell(maze, coord).links
    end)
    |> Enum.uniq()
  end

  # Calculate the distances for all cells in the maze starting from the root cell
  defp calc_cell_distances(%{} = distance_matrix, %Grid{} = maze, %Coordinate{} = root_cell_coord) do
    apply_distances(distance_matrix, maze, [root_cell_coord], 0)
  end

  # Base case: no more cells to update, return the current distance matrix
  defp apply_distances(%{} = distance_matrix, %Grid{}, [], _) do
    distance_matrix
  end

  # Recursive case: update distances for the given list of cell coordinates
  defp apply_distances(
         %{} = distance_matrix,
         %Grid{} = maze,
         for_cell_coords,
         distance
       ) do
    unset_coords = filter_unset_coords(for_cell_coords, distance_matrix)
    updated_matrix = set_distance(distance_matrix, unset_coords, distance)
    link_coords = find_links(maze, unset_coords)
    apply_distances(updated_matrix, maze, link_coords, distance + 1)
  end

  # Initialize a matrix with nil values for all cells
  defp initialize_matrix(num_rows, num_cols) do
    # Outer map's keys are row indices
    Enum.reduce(1..num_rows, %{}, fn row_num, acc_matrix ->
      # Inner map's keys are column indices
      new_row =
        Enum.reduce(1..num_cols, %{}, fn col_num, acc_row ->
          Map.put(acc_row, col_num, nil)
        end)

      Map.put(acc_matrix, row_num, new_row)
    end)
  end
end
