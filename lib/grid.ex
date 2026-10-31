defmodule Grid do
  @moduledoc """
  Represents a grid of cells in a maze.

  ## Fields
    - `num_rows`: The number of rows in the grid (integer).
    - `num_cols`: The number of columns in the grid (integer).
    - `matrix`: A two-dimensional matrix of cells (map of maps), where the outer
    map's keys are row indices and the inner map's keys are column indices. Each
    cell is represented by a `Cell` struct. Row and column indices are 1-based.
  """

  @type t :: %__MODULE__{
          num_rows: non_neg_integer(),
          num_cols: non_neg_integer()
        }

  @enforce_keys [:num_rows, :num_cols]
  defstruct [:num_rows, :num_cols, matrix: %{}]

  @doc """
  Creates a new grid with the given number of rows and columns. The grid is
  initialized with a two-dimensional matrix of cells, where each cell is
  represented by a `Cell` struct. Row and column indices are 1-based.

  ## Parameters
    - `num_rows`: The number of rows in the grid (positive integer).
    - `num_cols`: The number of columns in the grid (positive integer).

  ## Returns
    - A new `%Grid{}` struct representing the grid.
  """
  def new(num_rows, num_cols)
      when is_integer(num_rows) and is_integer(num_cols) and num_rows > 0 and num_cols > 0 do
    %__MODULE__{
      num_rows: num_rows,
      num_cols: num_cols,
      matrix: generate_matrix(num_rows, num_cols)
    }
  end

  @doc """
  Returns the total number of cells in the grid.
  """
  def size(%__MODULE__{num_rows: num_rows, num_cols: num_cols}) do
    num_rows * num_cols
  end

  # ==========================
  # Cells
  # ==========================

  @doc """
  Returns a cell at the given coordinates.
  """
  def get_cell(%__MODULE__{} = grid, %Coordinate{row: row, col: col}),
    do: get_cell(grid, row, col)

  def get_cell(%__MODULE__{matrix: matrix}, row, col) when is_integer(row) and is_integer(col) do
    case Map.get(matrix, row) do
      nil -> nil
      row_map -> Map.get(row_map, col)
    end
  end

  @doc """
  Returns a random cell from the grid.
  """
  def get_random_cell(%__MODULE__{} = grid) do
    row = :rand.uniform(grid.num_rows)
    col = :rand.uniform(grid.num_cols)
    get_cell(grid, row, col)
  end

  # ==========================
  # Cell Neighbors
  # ==========================

  @doc """
  Returns the neighboring cell relative to the given cell or grid location and in
  the specified direction. Returns `nil` if there is no neighbor in that direction.
  """
  def get_neighbor(%__MODULE__{} = grid, %Cell{coord: coord}, direction)
      when is_atom(direction) do
    get_neighbor(grid, coord, direction)
  end

  def get_neighbor(%__MODULE__{} = grid, %Coordinate{row: row, col: col}, direction)
      when is_atom(direction) do
    case direction do
      :north -> get_cell(grid, row - 1, col)
      :south -> get_cell(grid, row + 1, col)
      :east -> get_cell(grid, row, col + 1)
      :west -> get_cell(grid, row, col - 1)
    end
  end

  @doc """
  Returns a list of all neighbors of the given cell.
  """
  def neighbors_of(%__MODULE__{} = grid, %Cell{} = cell) do
    [
      get_neighbor(grid, cell, :north),
      get_neighbor(grid, cell, :south),
      get_neighbor(grid, cell, :east),
      get_neighbor(grid, cell, :west)
    ]
    |> Enum.reject(&is_nil/1)
  end

  @doc """
  Does a cell have a neighbor in the given direction?
  """
  def has_neighbor?(%__MODULE__{} = grid, %Cell{coord: coord}, direction) do
    has_neighbor?(grid, coord, direction)
  end

  def has_neighbor?(%__MODULE__{} = grid, %Coordinate{row: row, col: col}, direction) do
    case direction do
      :north -> row > 1
      :south -> row < grid.num_rows
      :east -> col < grid.num_cols
      :west -> col > 1
    end
  end

  # ==========================
  # Cell Links
  # ==========================

  @doc """
  Links two adjacent cells in the grid. The cells must be horizontally or
  vertically adjacent. If the cells are not adjacent, an `ArgumentError` is
  raised. If either cell is nil, the function does nothing and returns the
  original grid, otherwise the function links the two cells in both directions
  and returns a new grid with the updated links between the cells.
  """
  def link_cells(
        %__MODULE__{matrix: matrix} = grid,
        %Cell{} = cell1,
        %Cell{} = cell2
      ) do
    # Validate that the cells are not the same and adjacent
    if cell1 == cell2, do: raise(ArgumentError, "Cannot link a cell to itself.")

    if not_adjacent?(cell1, cell2),
      do: raise(ArgumentError, "Cells must be horizontally or vertically adjacent to link.")

    # Link the cells in both directions and update the grid's matrix
    updated_cell1 = Cell.link(cell1, cell2)
    updated_cell2 = Cell.link(cell2, cell1)

    # Add the updated cells to the grid's matrix
    coord1 = updated_cell1.coord
    updated_matrix = put_in(matrix[coord1.row][coord1.col], updated_cell1)

    coord2 = updated_cell2.coord
    updated_matrix = put_in(updated_matrix[coord2.row][coord2.col], updated_cell2)

    %{grid | matrix: updated_matrix}
  end

  def link_cells(%__MODULE__{} = grid, %Cell{}, nil) do
    # Do nothing if the second cell is nil (no neighbor to link to)
    grid
  end

  def link_cells(%__MODULE__{} = grid, nil, %Cell{}) do
    # Do nothing if the first cell is nil (no neighbor to link to)
    grid
  end

  def has_link?(%__MODULE__{} = grid, %Cell{} = cell, direction) do
    Cell.linked?(cell, Grid.get_neighbor(grid, cell, direction))
  end

  # ==========================
  # Internal Functions
  # ==========================

  # Generate a two-dimensional matrix of cells.
  #
  # An example of the resulting structure for a 2x2 grid:
  # %{
  #   1 => %{
  #     1 => %Cell{row: 1, col: 1},
  #     2 => %Cell{row: 1, col: 2}
  #   },
  #   2 => %{
  #     1 => %Cell{row: 2, col: 1},
  #     2 => %Cell{row: 2, col: 2}
  #   }
  # }
  defp generate_matrix(num_rows, num_cols) do
    matrix = %{}

    # Outer map's keys are row indices
    Enum.reduce(1..num_rows, matrix, fn row, matrix_acc ->
      # Inner map's keys are column indices
      new_row =
        Enum.reduce(1..num_cols, %{}, fn col, row_acc ->
          Map.put(row_acc, col, Cell.new(row, col))
        end)

      Map.put(matrix_acc, row, new_row)
    end)
  end

  # Check if two cells are not vertically or horizontally adjacent.
  defp not_adjacent?(
         %Cell{coord: %Coordinate{row: r1, col: c1}},
         %Cell{coord: %Coordinate{row: r2, col: c2}}
       ) do
    (r1 == r2 and abs(c1 - c2) != 1) or
      (abs(r1 - r2) != 1 and c1 == c2) or
      (r1 != r2 and c1 != c2)
  end
end

# ****************************

defimpl String.Chars, for: Grid do
  def to_string(%Grid{} = grid), do: Renderer.to_string(grid)
end
