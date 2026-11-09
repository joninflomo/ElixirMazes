defmodule Maze do
  @moduledoc """
  Documentation for `Maze`.
  """

  @doc """
  Generate a 5x5 maze using the Binary Tree algorithm.

  ## Examples

      iex> Maze.binary_tree_maze()
      +---+---+---+---+---+
      |                   |
      +   +---+   +---+   +
      |   |       |       |
      +   +---+---+---+   +
      |   |               |
      +   +---+---+---+   +
      |   |               |
      +   +   +---+   +   +
      |   |   |       |   |
      +---+---+---+---+---+
  """
  def binary_tree_maze(format \\ :text, filename \\ "binary_tree.png") do
    maze = BinaryTreeMaze.generate(5, 5)
    output_maze(maze, format, filename)
  end

  def binary_tree_maze_dist() do
    maze = BinaryTreeMaze.generate(5, 5)
    output_maze_with_dist(maze)
  end

  @doc """
    Generate a 5x5 maze using the Sidewinder algorithm.

    ## Examples

        iex> Maze.sidewinder_maze()
        +---+---+---+---+---+
        |                   |
        +   +---+   +---+   +
        |       |   |       |
        +   +---+---+   +   +
        |   |           |   |
        +---+   +---+   +---+
        |       |           |
        +   +---+   +---+---+
        |       |           |
        +---+---+---+---+---+
  """
  def sidewinder_maze(format \\ :text, filename \\ "sidewinder.png") do
    maze = SidewinderMaze.generate(5, 5)
    output_maze(maze, format, filename)
  end

  def sidewinder_maze_dist() do
    maze = SidewinderMaze.generate(5, 5)
    output_maze_with_dist(maze)
  end

  # ==========================
  # Internal
  # ==========================

  defp output_maze(maze, :text, _) do
    # IO.puts("#{Renderer.to_ascii(maze)}")
    IO.puts(maze)
  end

  defp output_maze(maze, :png, filename) do
    IO.puts("Writing image to file #{filename}")
    Image.write!(Renderer.to_png(maze), filename)
    :ok
  end

  defp output_maze_with_dist(maze) do
    dist = Distances.calculate(maze, 1, 1)

    str =
      Renderer.to_ascii(maze, fn cell ->
        Integer.to_string(Distances.get_cell_distance(dist, cell.coord), 36)
      end)

    IO.puts(str)
  end
end
