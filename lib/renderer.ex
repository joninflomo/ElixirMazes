defmodule Renderer do
  @moduledoc """
    Renders a maze in different formats.
  """

  @doc """
  Converts a grid to a string representation.
  """
  def to_string(%Grid{} = grid) do
    str = maze_north_border_string(grid)

    Enum.reduce(1..grid.num_rows, str, fn row_num, str_acc ->
      str_acc <> row_content_string(grid, row_num) <> row_south_border_string(grid, row_num)
    end)
  end

  @doc """
  Converts a grid to a PNG representation.
  """
  def to_png(%Grid{} = grid, cell_size \\ 10) do
    img_width = grid.num_cols * cell_size
    img_height = grid.num_rows * cell_size

    {:ok, img} = Image.new(img_width + 1, img_height + 1, color: :white)

    for row <- 1..grid.num_rows, col <- 1..grid.num_cols, reduce: img do
      acc -> draw_cell(acc, grid, Coordinate.new(row, col), cell_size)
    end
  end

  # ==========================
  # Internal - Text Version
  # ==========================

  @corner "+"
  @body "   "
  @v_wall "|"
  @v_open " "
  @h_wall "---"
  @h_open @body

  # Draw the northern boundary (horizontal wall) of the grid.
  defp maze_north_border_string(grid) do
    @corner <> String.duplicate(@h_wall <> @corner, grid.num_cols) <> "\n"
  end

  # Draw a row of cells, including the vertical boundaries between them.
  defp row_content_string(grid, row_num) do
    content =
      Enum.reduce(1..grid.num_cols, @v_wall, fn col_num, string_acc ->
        cell = Grid.get_cell(grid, row_num, col_num)
        east_boundary = if Grid.has_link?(grid, cell, :east), do: @v_open, else: @v_wall

        string_acc <> @body <> east_boundary
      end)

    content <> "\n"
  end

  # Draw the southern boundary (horizontal walls) of a row of cells.
  defp row_south_border_string(grid, row_num) do
    content =
      Enum.reduce(1..grid.num_cols, @corner, fn col_num, string_acc ->
        cell = Grid.get_cell(grid, row_num, col_num)
        south_boundary = if Grid.has_link?(grid, cell, :south), do: @h_open, else: @h_wall

        string_acc <> south_boundary <> @corner
      end)

    content <> "\n"
  end

  # ==========================
  # Internal - PNG Version
  # ==========================

  # Draws a cell onto an image. Returns an updated image.
  defp draw_cell(%Vix.Vips.Image{} = image, %Grid{} = grid, %Coordinate{} = coord, cell_size)
       when is_integer(cell_size) do
    # Cell's upper left corner - 0,0 is at the upper left of the image
    x1 = (coord.col - 1) * cell_size
    y1 = (coord.row - 1) * cell_size

    # Cell's lower right corner
    x2 = x1 + cell_size
    y2 = y1 + cell_size

    # Draw the walls of the cell onto the image
    cell = Grid.get_cell(grid, coord)

    image
    |> draw_wall(Grid.has_neighbor?(grid, cell, :north), {x1, y1, x2, y1})
    |> draw_wall(Grid.has_neighbor?(grid, cell, :west), {x1, y1, x1, y2})
    |> draw_wall(Grid.has_link?(grid, cell, :east), {x2, y1, x2, y2})
    |> draw_wall(Grid.has_link?(grid, cell, :south), {x1, y2, x2, y2})
  end

  # Draws a cell wall on an image. Returns an updated image.
  defp draw_wall(image, hide, dimensions)
  defp draw_wall(image, true, _), do: image

  defp draw_wall(image, _, {x1, y1, x2, y2}) do
    Image.Draw.line!(image, x1, y1, x2, y2, color: :black)
  end
end
