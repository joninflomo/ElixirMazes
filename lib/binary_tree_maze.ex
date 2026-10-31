defmodule BinaryTreeMaze do
  @moduledoc """
  Implementation of the Binary Tree maze generation algorithm.
  """

  @doc """
  Generates a maze with the specified dimensions.
  """
  def generate(num_rows, num_cols) do
    grid = Grid.new(num_rows, num_cols)

    for row <- 1..grid.num_rows, col <- 1..grid.num_cols, reduce: grid do
      acc -> process_cell_at(acc, row, col)
    end
  end

  # ==========================
  # Internal Functions
  # ==========================

  # Processes a cell at the given row and column in the grid, linking it to a
  # randomly chosen neighbor (north or east) if available.
  defp process_cell_at(grid, cell_row, cell_col) do
    cell = Grid.get_cell(grid, cell_row, cell_col)

    # Determine the neighbors to the north and east of the current cell
    ne_neighbors =
      [Grid.get_neighbor(grid, cell, :north), Grid.get_neighbor(grid, cell, :east)]
      |> Enum.reject(&is_nil/1)

    if length(ne_neighbors) == 0 do
      # No neighbors to link to, return the grid unchanged
      grid
    else
      # Randomly select a neighbor and link the cell to it
      neighbor = Enum.random(ne_neighbors)
      Grid.link_cells(grid, cell, neighbor)
    end
  end
end
