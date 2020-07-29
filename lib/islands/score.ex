# ┌───────────────────────────────────────────────────────────────────────┐
# │ Inspired by the book "Functional Web Development" by Lance Halvorsen. │
# └───────────────────────────────────────────────────────────────────────┘
defmodule Islands.Score do
  @moduledoc """
  Creates a `score` struct for the _Game of Islands_.
  \n##### #{Islands.Config.get(:book_ref)}
  """

  alias __MODULE__
  alias Islands.{Board, Game, Island, Player, PlayerID}

  @player_ids [:player1, :player2]

  @derive [Poison.Encoder]
  @derive Jason.Encoder
  @enforce_keys [:name, :gender, :hits, :misses, :forested_types]
  defstruct [:name, :gender, :hits, :misses, :forested_types]

  @type t :: %Score{
          name: String.t(),
          gender: Player.gender(),
          hits: non_neg_integer,
          misses: non_neg_integer,
          forested_types: [Island.type()]
        }

  @spec board_score(Game.t(), PlayerID.t()) :: t
  def board_score(%Game{} = game, player_id) when player_id in @player_ids do
    player = game[player_id]
    board = player.board
    new(player, board)
  end

  @spec guesses_score(Game.t(), PlayerID.t()) :: t
  def guesses_score(%Game{} = game, player_id) when player_id in @player_ids do
    opponent = game[Game.opponent_id(player_id)]
    board = opponent.board
    new(opponent, board)
  end

  ## Private functions

  @spec new(Player.t(), Board.t() | nil) :: t
  defp new(player, nil) do
    %Score{
      name: player.name,
      gender: player.gender,
      hits: 0,
      misses: 0,
      forested_types: []
    }
  end

  defp new(player, board) do
    %Score{
      name: player.name,
      gender: player.gender,
      hits: Board.hits(board),
      misses: Board.misses(board),
      forested_types: Board.forested_types(board)
    }
  end
end
