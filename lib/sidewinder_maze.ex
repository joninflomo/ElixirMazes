defmodule SidewinderMaze do
  @moduledoc """
  Implementation of the Sidewinder maze generation algorithm.
  """

  @doc """
  Generates a maze with the specified dimensions.
  """
  def generate(num_rows, num_cols) do
    grid = Grid.new(num_rows, num_cols)

    for row <- 1..grid.num_rows, reduce: grid do
      acc -> process_row(acc, row)
    end
  end

  # ==========================
  # Internal Functions
  # ==========================

  defp process_row(grid, row_num) do
    run = []

    {updated_grid, _} =
      Enum.reduce(1..grid.num_cols, {grid, run}, fn col, {acc_grid, acc_run} ->
        cell = Grid.get_cell(acc_grid, row_num, col)

        # Build up the run of cells visited - only store coordinates to avoid
        # getting out of sync with cells in the accumulated grid
        acc_run = [cell.coord | acc_run]

        # Boundaries determine where we can carve passages. If we're at the
        # eastern boundary, we must close the run.
        at_eastern_boundary = col == acc_grid.num_cols
        at_northern_boundary = row_num == 1
        close_the_run = at_eastern_boundary || (!at_northern_boundary && :rand.uniform(2) == 1)

        if close_the_run do
          # Pick a random cell from the run
          random_cell = Grid.get_cell(acc_grid, Enum.random(acc_run))
          north_of_random_cell = Grid.get_neighbor(acc_grid, random_cell, :north)

          # Try to open a passage to the north
          if north_of_random_cell do
            # Open a northern passage and reset the run
            new_grid = Grid.link_cells(acc_grid, random_cell, north_of_random_cell)
            {new_grid, []}
          else
            # Can't go north so don't change anything
            {acc_grid, []}
          end
        else
          # Open a passage to the east and continue the run
          east_of_cell = Grid.get_neighbor(acc_grid, cell, :east)
          new_grid = Grid.link_cells(acc_grid, cell, east_of_cell)
          {new_grid, acc_run}
        end
      end)

    updated_grid
  end
end
