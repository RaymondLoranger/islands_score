# ┌───────────────────────────────────────────────────────────────────────┐
# │ Inspired by the book "Functional Web Development" by Lance Halvorsen. │
# └───────────────────────────────────────────────────────────────────────┘
defmodule Islands.Score do
  @moduledoc """
  A score struct and functions for the _Game of Islands_.

  The score struct contains the fields:

    - `name`
    - `gender`
    - `hits`
    - `misses`
    - `forested_types`

  representing the properties of a score in the _Game of Islands_.

  ##### Inspired by the book [Functional Web Development](https://pragprog.com/titles/lhelph/functional-web-development-with-elixir-otp-and-phoenix/) by Lance Halvorsen.
  """

  alias __MODULE__
  alias IO.ANSI.Plus, as: ANSI
  alias Islands.Client.IslandType
  alias Islands.{Board, Game, Island, Player, PlayerID}

  @island_type_codes ["a", "d", "l", "s", "q"]
  @player_ids [:player1, :player2]
  @score_width 21
  @sp ANSI.cursor_right()
  @sp_gender 2
  @symbols [f: "♀", m: "♂"]

  @derive JSON.Encoder
  @enforce_keys [:name, :gender, :hits, :misses, :forested_types]
  defstruct [:name, :gender, :hits, :misses, :forested_types]

  @typedoc "A score struct for the Game of Islands"
  @type t :: %Score{
          name: Player.name(),
          gender: Player.gender(),
          hits: non_neg_integer,
          misses: non_neg_integer,
          forested_types: [Island.type()]
        }

  @doc """
  Creates a score struct from a player's board struct.
  """
  @spec board_score(Game.t(), PlayerID.t()) :: t
  def board_score(%Game{} = game, player_id) when player_id in @player_ids do
    player = game[player_id]
    board = player.board
    new(player, board)
  end

  @doc """
  Creates a score struct from an opponent's board struct.
  """
  @spec guesses_score(Game.t(), PlayerID.t()) :: t
  def guesses_score(%Game{} = game, player_id) when player_id in @player_ids do
    opponent = game[Game.opponent_id(player_id)]
    board = opponent.board
    new(opponent, board)
  end

  @doc """
  Prints `score` formatted with embedded ANSI escapes.
  """
  @spec format(t, keyword) :: :ok
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

  @spec new(Player.t(), Board.t()) :: t
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
    name = String.slice(name, 0, @score_width - @sp_gender)
    span = div(@score_width + String.length(name) + @sp_gender, 2) - @sp_gender

    # The "visible" width of `player/1` (ignoring ANSI escapes) is 11 to 21...
    [
      [:chartreuse_yellow, String.pad_leading(name, span)],
      [:reset, @sp, :spring_green, "#{@symbols[gender]}"]
    ]
  end

  @spec top_score(t) :: ANSI.ansilist()
  defp top_score(%Score{hits: hits, misses: misses}) do
    # The "visible" width of `top_score/1` (ignoring ANSI escapes) is 21...
    [
      [:chartreuse_yellow, "hits: "],
      [:spring_green, String.pad_leading("#{hits}", 2)],
      [:chartreuse_yellow, "   misses: "],
      [:spring_green, String.pad_leading("#{misses}", 2)]
    ]
  end

  @spec bottom_score(t) :: ANSI.ansilist()
  defp bottom_score(score) do
    # The "visible" width of `bottom_score/1` (ignoring ANSI escapes) is 20...
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
  defp attr(_forested? = true), do: [:reset, @sp, :spring_green, :underline]
  defp attr(_forested?), do: [:reset, @sp, :chartreuse_yellow]
end
