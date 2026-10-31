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

  # ==========================
  # Internal
  # ==========================

  defp output_maze(maze, :text, _) do
    IO.puts(maze)
  end

  defp output_maze(maze, :png, filename) do
    IO.puts("Writing image to file #{filename}")
    Image.write!(Renderer.to_png(maze), filename)
    :ok
  end
end
