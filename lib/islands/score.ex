# ┌───────────────────────────────────────────────────────────────────────┐
# │ Inspired by the book "Functional Web Development" by Lance Halvorsen. │
# └───────────────────────────────────────────────────────────────────────┘
defmodule Islands.Score do
  @moduledoc """
  Creates a `score` struct for the _Game of Islands_.
  Also formats the `score` of a player.

  ##### Inspired by the book [Functional Web Development](https://pragprog.com/book/lhelph/functional-web-development-with-elixir-otp-and-phoenix) by Lance Halvorsen.
  """

  alias __MODULE__
  alias IO.ANSI.Plus, as: ANSI
  alias Islands.Client.IslandType
  alias Islands.{Board, Game, Island, Player, PlayerID}

  @island_type_codes ["a", "d", "l", "s", "q"]
  @player_ids [:player1, :player2]
  @sp ANSI.cursor_right()
  @symbols [f: "♀", m: "♂"]

  @derive [Poison.Encoder]
  @derive Jason.Encoder
  @enforce_keys [:name, :gender, :hits, :misses, :forested_types]
  defstruct [:name, :gender, :hits, :misses, :forested_types]

  @type t :: %Score{
          name: Player.name(),
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

  @spec format(t, Keyword.t()) :: :ok
  def format(%Score{} = score, options) do
    {up, right} = {options[:up], options[:right]}

    [
      [cursor_up(up), ANSI.cursor_right(right), player(score)],
      ["\n", ANSI.cursor_right(right), top_score(score)],
      ["\n", ANSI.cursor_right(right), bottom_score(score)]
    ]
    |> ANSI.puts()
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

  @spec cursor_up(non_neg_integer) :: String.t()
  defp cursor_up(up) when up > 0, do: ANSI.cursor_up(up)
  defp cursor_up(_up), do: ""

  @spec player(t) :: ANSI.ansilist()
  defp player(%Score{name: name, gender: gender}) do
    name = String.slice(name, 0, 21 - 2)
    span = div(21 + String.length(name) + 2, 2) - 2

    [
      [:chartreuse_yellow, String.pad_leading(name, span)],
      [:reset, @sp, :spring_green, "#{@symbols[gender]}"]
    ]
  end

  @spec top_score(t) :: ANSI.ansilist()
  defp top_score(%Score{hits: hits, misses: misses}) do
    [
      [:chartreuse_yellow, "hits: "],
      [:spring_green, String.pad_leading("#{hits}", 2)],
      [:chartreuse_yellow, "   misses: "],
      [:spring_green, String.pad_leading("#{misses}", 2)]
    ]
  end

  @spec bottom_score(t) :: ANSI.ansilist()
  defp bottom_score(score) do
    [
      [:reset, :spring_green, :underline, "forested"],
      [:reset, @sp, :chartreuse_yellow, "➔", forested_codes(score)]
    ]
  end

  @spec forested_codes(t) :: ANSI.ansilist()
  defp forested_codes(%Score{forested_types: forested_types}) do
    for code <- @island_type_codes do
      [attr(IslandType.new(code) in forested_types), code]
    end
  end

  @spec attr(boolean) :: ANSI.ansilist()
  defp attr(true = _forested?), do: [:reset, @sp, :spring_green, :underline]
  defp attr(false = _forested?), do: [:reset, @sp, :chartreuse_yellow]
end
