defmodule Coordinate do
  @moduledoc """
  Represents a location in a grid.
  """

  @type t :: %__MODULE__{
          row: integer(),
          col: integer()
        }
  @enforce_keys [:row, :col]
  defstruct [:row, :col]

  def new(row, col) when is_integer(row) and is_integer(col) do
    %__MODULE__{row: row, col: col}
  end
end
