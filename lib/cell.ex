defmodule Cell do
  @moduledoc """
  Represents a cell in a maze, with its row and column coordinates and any
  links to neighboring cells.

  ## Fields
    - `coord`: The location of the cell in a grid.
    - `links`: A list of linked neighboring cells (`Cell` structs).
  """

  @type t :: %__MODULE__{
          coord: Coordinate.t(),
          links: [Coordinate.t()]
        }

  @enforce_keys [:coord]
  defstruct [:coord, links: []]

  @doc """
  Creates a new cell with the given row and column coordinates.
  """
  def new(row, col) when is_integer(row) and row > 0 and is_integer(col) and col > 0 do
    %__MODULE__{coord: Coordinate.new(row, col)}
  end

  @doc """
  Links a cell to a neighboring cell.
  """
  def link(%__MODULE__{} = cell, %__MODULE__{} = neighbor) do
    %{cell | links: [neighbor.coord | cell.links]}
  end

  @doc """
  Unlinks a cell from a neighboring cell.
  """
  def unlink(%__MODULE__{} = cell, %__MODULE__{} = neighbor) do
    %{cell | links: List.delete(cell.links, neighbor.coord)}
  end

  @doc """
  Checks if a cell is linked to a neighboring cell.
  """
  def linked?(%__MODULE__{} = cell, %__MODULE__{} = neighbor) do
    neighbor.coord in cell.links
  end

  def linked?(%__MODULE__{} = _cell, nil), do: nil
end
