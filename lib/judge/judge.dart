import 'package:meta/meta.dart';

import 'package:tic_tac_no/game/data/models/grid.dart';
import 'package:tic_tac_no/game/data/models/models.dart';
import 'package:tic_tac_no/game/data/models/player.dart';
import 'package:tic_tac_no/game/data/models/square.dart';

class Judge {
  List<Player> players;
  Grid _grid;
  Player _currentPlayer;
  Map<int, int> _score;
  Player _winner;
  bool _isGameOver = false;

  Judge({
    this.players,
    @required grid,
  }) {
    this._currentPlayer = this.players != null ? this.players[0] : null;
    this._grid = grid;
    if (this.players != null) {
      _score = {
        players[0].id: 0,
        players[1].id: 0,
      };
    }
  }

  Grid getGrid() => this._grid;
  Player getCurrentPlayer() => this._currentPlayer;
  Map<int, int> get score => _score;
  Player getWinner() => this._winner;
  bool getIsGameOver() => this._isGameOver;

  void updatePlayers(List<Player> players) {
    this.players = players;
    this._currentPlayer = this.players != null ? this.players[0] : null;
    if (_score == null) {
      _score = {
        players[0].id: 0,
        players[1].id: 0,
      };
    }
    _updateGrid();
  }

  void _updateGrid() {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (this._grid.innerGrids[i][j].winner != null) {
          final Player winner = this._grid.innerGrids[i][j].winner;
          this._grid.innerGrids[i][j].winner =
              this.players.firstWhere((player) => player.id == winner.id);
        }
        for (int k = 0; k < 3; k++) {
          for (int l = 0; l < 3; l++) {
            if (this._grid.innerGrids[i][j].squares[k][l].player != null) {
              final Player oldPlayer =
                  this._grid.innerGrids[i][j].squares[k][l].player;
              this._grid.innerGrids[i][j].squares[k][l].player = this
                  .players
                  .firstWhere((player) => player.id == oldPlayer.id);
            }
          }
        }
      }
    }
  }

  void updateGame(Square tappedSquare) {
    // check if move can be made at this square
    if (tappedSquare.parentInnerGrid.isPlayable == false) {
      return;
    }
    if (tappedSquare.player != null) {
      return;
    }

    final Position innerGridPosition = tappedSquare.parentInnerGrid.position;
    // update square's player (occupant)
    _grid
        .innerGrids[innerGridPosition.x][innerGridPosition.y]
        .squares[tappedSquare.position.x][tappedSquare.position.y]
        .player = this._currentPlayer;

    // mark all inner grids unplayable
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        this._grid.innerGrids[i][j].isPlayable = false;
      }
    }

    // check did current player win
    if (tappedSquare.parentInnerGrid.winner == null) {
      if (this._didWin(tappedSquare.parentInnerGrid)) {
        _grid.innerGrids[innerGridPosition.x][innerGridPosition.y].winner =
            this._currentPlayer;
        _score[_currentPlayer.id]++;
        // chick did current player win entire game
        if (this._didWinGame()) {
          this._isGameOver = true;
          this._winner = this._currentPlayer;
        }
      }
    }

    // mark next playable innerGrid
    if (_grid.innerGrids[tappedSquare.position.x][tappedSquare.position.y]
        .hasRoom()) {
      _grid.innerGrids[tappedSquare.position.x][tappedSquare.position.y]
          .isPlayable = true;
    } else {
      // choose random
      final Position position =
          this._grid.getRandomInnerGridPositionThatHasRoom();
      if (position.x != -1) {
        _grid.innerGrids[position.x][position.y].isPlayable = true;
      } else {
        // end game as a tie
        this._isGameOver = true;
        if (_score[players[0].id] > _score[players[1].id]) {
          this._winner = players[0];
        } else if (_score[players[0].id] < _score[players[1].id]) {
          this._winner = players[1];
        } else {
          this._winner = null;
        }
      }
    }

    // change current player
    this._currentPlayer = this
        .players
        .firstWhere((player) => player.id != this._currentPlayer.id);
  }

  bool _didWin(InnerGrid innerGrid) {
    ///    xxx         ___          ___
    ///    ___    OR   xxx    OR    ___
    ///    ___         ___          xxx
    for (int i = 0; i < 3; i++) {
      if (innerGrid.squares[i][0].player == this._currentPlayer &&
          innerGrid.squares[i][1].player == this._currentPlayer &&
          innerGrid.squares[i][2].player == this._currentPlayer) {
        return true;
      }
    }

    ///    x__         _x_          __x
    ///    x__    OR   _x_    OR    __x
    ///    x__         _x_          __x
    for (int i = 0; i < 3; i++) {
      if (innerGrid.squares[0][i].player == this._currentPlayer &&
          innerGrid.squares[1][i].player == this._currentPlayer &&
          innerGrid.squares[2][i].player == this._currentPlayer) {
        return true;
      }
    }

    ///    x__
    ///    _x_
    ///    __x
    if (innerGrid.squares[0][0].player == this._currentPlayer &&
        innerGrid.squares[1][1].player == this._currentPlayer &&
        innerGrid.squares[2][2].player == this._currentPlayer) {
      return true;
    }

    ///    __x
    ///    _x_
    ///    x__
    if (innerGrid.squares[0][2].player == this._currentPlayer &&
        innerGrid.squares[1][1].player == this._currentPlayer &&
        innerGrid.squares[2][0].player == this._currentPlayer) {
      return true;
    }

    return false;
  }

  bool _didWinGame() {
    ///    xxx         ___          ___
    ///    ___    OR   xxx    OR    ___
    ///    ___         ___          xxx
    for (int i = 0; i < 3; i++) {
      if (this._grid.innerGrids[i][0].winner == this._currentPlayer &&
          this._grid.innerGrids[i][1].winner == this._currentPlayer &&
          this._grid.innerGrids[i][2].winner == this._currentPlayer) {
        return true;
      }
    }

    ///    x__         _x_          __x
    ///    x__    OR   _x_    OR    __x
    ///    x__         _x_          __x
    for (int i = 0; i < 3; i++) {
      if (this._grid.innerGrids[0][i].winner == this._currentPlayer &&
          this._grid.innerGrids[1][i].winner == this._currentPlayer &&
          this._grid.innerGrids[2][i].winner == this._currentPlayer) {
        return true;
      }
    }

    ///    x__
    ///    _x_
    ///    __x
    if (this._grid.innerGrids[0][0].winner == this._currentPlayer &&
        this._grid.innerGrids[1][1].winner == this._currentPlayer &&
        this._grid.innerGrids[2][2].winner == this._currentPlayer) {
      return true;
    }

    ///    __x
    ///    _x_
    ///    x__
    if (this._grid.innerGrids[0][2].winner == this._currentPlayer &&
        this._grid.innerGrids[1][1].winner == this._currentPlayer &&
        this._grid.innerGrids[2][0].winner == this._currentPlayer) {
      return true;
    }

    return false;
  }
}
