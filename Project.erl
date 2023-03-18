-module(my_game).
-export([start/0, play/3, print_board/1, game_over/1]).

start() ->
    Board = [[0,0,0],[0,0,0],[0,0,0]],
    Player = 1,
    play(Player, Board, []).


play(Player, Board, Moves) ->
    case game_over(Board) of
        {true, Winner} ->
            io:format("Game over! Player ~w has won.~n", [Winner]);
        {false, draw} ->
            io:format("Game over! It's a draw.~n");
        _ ->
            io:format("Player ~w's turn.~n", [Player]),
            print_board(Board),
           
            io:format("Enter a row and column (e.g. 1,2): "),
            case io:fread("~,d,~,d~n", []) of
                {ok, [Row, Column]} ->
                    case make_move(Player, Row, Column, Board) of
                       
                         {ok, NewBoard} ->
                            NewMoves = [{Player, Row, Column}|Moves],
                            NextPlayer = case Player of
                                1 -> 2;
                                2 -> 1
                            end,
                            play(NextPlayer, NewBoard, NewMoves);
                        error ->
                            io:format("Invalid move.~n"),
                            play(Player, Board, Moves)
                    end;
                _ ->
                    io:format("Invalid input.~n"),
                    play(Player, Board, Moves)
            end
    end.

print_board(Board) ->
    io:format("   1 2 3~n"),
    io:format("   -------~n"),
    print_rows(Board, 1).

print_rows([], _) ->
    ok;
print_rows([Row|Rows], N) ->
    io:format("~w |", [N]),
    print_cells(Row),
    io:format("~n   -------~n"),
    print_rows(Rows, N+1).

print_cells([]) ->
    ok;
print_cells([Cell|Cells]) ->
    case Cell of
        0 ->
            io:format(" ");
        1 ->
            io:format("X");
        2 ->
            io:format("O")
    end,
    io:format("|"),
    print_cells(Cells).

make_move(Player, Row, Column, Board) ->
    case get_cell(Row, Column, Board) of
        0 ->
            NewBoard = set_cell(Row, Column, Player, Board),
            {ok, NewBoard};
        _ ->
            error
    end.

get_cell(Row, Column, Board) ->
    lists:nth(Row, Board, []) |> lists:nth(Column, []).

set_cell(Row, Column, Value, Board) ->
    Rows1 = lists:sublist(Board, Row-1),
    Row1 = lists:nth(Row, Board, []),
    Cells1 = lists:sublist(Row1, Column-1),
    Cell1 = lists:nth(Column, Row1, 0),
    Cells2 = lists:nthtail(Column, Row1),
    Row2 = [Cell1|Cells1++[Value]++Cells2],
    Rows2 = lists:nthtail(Row, Board),
    NewBoard = Rows1++[Row2]++Rows2,
    NewBoard.


game_over(Board) ->
    case winner(Board) of
        {true, Winner} ->
            {true, Winner};
        {false, _} ->
            case draw(Board) of
                true ->
                    {false, draw}

