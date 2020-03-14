defmodule Islands.ScoreTest do
  use ExUnit.Case, async: true

  alias Islands.{Board, Coord, Game, Island, Score}

  doctest Score

  setup_all do
    # See Player's Board in Functional Web Development on page 13...
    {:ok, atoll_coord} = Coord.new(1, 1)
    {:ok, dot_coord} = Coord.new(9, 9)
    {:ok, l_shape_coord} = Coord.new(3, 7)
    {:ok, s_shape_coord} = Coord.new(6, 2)
    {:ok, square_coord} = Coord.new(9, 5)

    {:ok, atoll} = Island.new(:atoll, atoll_coord)
    {:ok, dot} = Island.new(:dot, dot_coord)
    {:ok, l_shape} = Island.new(:l_shape, l_shape_coord)
    {:ok, s_shape} = Island.new(:s_shape, s_shape_coord)
    {:ok, square} = Island.new(:square, square_coord)

    board =
      Board.new()
      |> Board.position_island(atoll)
      |> Board.position_island(dot)
      |> Board.position_island(l_shape)
      |> Board.position_island(s_shape)
      |> Board.position_island(square)

    {:hit, :none, :no_win, board} = Board.guess(board, atoll_coord)
    {:hit, :dot, :no_win, board} = Board.guess(board, dot_coord)
    {:hit, :none, :no_win, board} = Board.guess(board, l_shape_coord)
    {:miss, :none, :no_win, board} = Board.guess(board, s_shape_coord)
    {:hit, :none, :no_win, board} = Board.guess(board, square_coord)

    this = self()
    eden = Game.new("Eden", "Adam", :m, this)
    eden = Game.update_board(eden, :player1, board)
    eden = Game.update_player(eden, :player2, "Eve", :f, this)
    score = Score.board_score(eden, :player1)

    poison =
      ~s<{"name":"Adam","misses":1,"hits":4,"gender":"m","forested_types":["dot"]}>

    jason =
      ~s<{"forested_types":["dot"],"gender":"m","hits":4,"misses":1,"name":"Adam"}>

    decoded = %{
      "forested_types" => ["dot"],
      "hits" => 4,
      "misses" => 1,
      "gender" => "m",
      "name" => "Adam"
    }

    {:ok,
     json: %{poison: poison, jason: jason, decoded: decoded},
     score: score,
     game: eden}
  end

  describe "A score struct" do
    test "can be encoded by Poison", %{score: score, json: json} do
      assert Poison.encode!(score) == json.poison
      assert Poison.decode!(json.poison) == json.decoded
    end

    test "can be encoded by Jason", %{score: score, json: json} do
      assert Jason.encode!(score) == json.jason
      assert Jason.decode!(json.jason) == json.decoded
    end
  end

  describe "Score.board_score/2" do
    test "returns a `score` struct", %{game: eden} do
      assert Score.board_score(eden, :player1) == %Score{
               name: "Adam",
               gender: :m,
               hits: 4,
               misses: 1,
               forested_types: [:dot]
             }
    end
  end

  describe "Score.guesses_score/2" do
    test "returns a `score` struct", %{game: eden} do
      assert Score.guesses_score(eden, :player1) == %Score{
               name: "Eve",
               gender: :f,
               hits: 0,
               misses: 0,
               forested_types: []
             }
    end
  end
end
