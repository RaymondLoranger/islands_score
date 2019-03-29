# ┌───────────────────────────────────────────────────────────────────────┐
# │ Inspired by the book "Functional Web Development" by Lance Halvorsen. │
# └───────────────────────────────────────────────────────────────────────┘
defmodule Islands.Score do
  use PersistConfig

  @book_ref Application.get_env(@app, :book_ref)

  @moduledoc """
  Creates a `score` struct for the _Game of Islands_.
  \n##### #{@book_ref}
  """

  alias __MODULE__
  alias Islands.{Board, Island}

  @derive [Poison.Encoder]
  @derive Jason.Encoder
  @enforce_keys [:hits, :misses, :forested_types]
  defstruct [:hits, :misses, :forested_types]

  @type forested_types :: [Island.type()]
  @type hits :: non_neg_integer
  @type misses :: non_neg_integer
  @type t :: %Score{hits: hits, misses: misses, forested_types: forested_types}

  @doc """
  Creates a `score` struct for the _Game of Islands_.

  ## Examples

      iex> alias Islands.{Board, Score}
      iex> %Score{
      ...>   hits: hits,
      ...>   misses: misses,
      ...>   forested_types: forested_types
      ...> } = Board.new() |> Score.new()
      iex> {hits, misses, forested_types}
      {0, 0, []}
  """
  @spec new(Board.t()) :: t
  def new(%Board{} = board) do
    %Score{
      hits: Board.hits(board),
      misses: Board.misses(board),
      forested_types: Board.forested_types(board)
    }
  end
end
