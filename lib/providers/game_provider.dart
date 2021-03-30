import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tetris/entities/direction.dart';
import 'package:tetris/entities/game.dart';
import 'package:tetris/entities/position.dart';
import 'package:tetris/entities/rotation.dart';
import 'package:tetris/entities/shape.dart';

/// GameProvider
class GameProvider extends StateNotifier<Game> {
  /// GameProvider
  GameProvider() : super(Game());

  /*--------------------------------------------------------------------------*/
  /* State setters                                                            */
  /*--------------------------------------------------------------------------*/

  /// Moves the Shape in a certain direction
  void moveShape(Direction dir) {
    final shape = state.activeShape;
    final absRefPosition = state.activeShapePosition;
    var newAbsRefPosition = absRefPosition;
    if (shape == null || absRefPosition == null) return;
    final absPositions =
        shape.absPositions(base: absRefPosition.toPosition, direction: dir);
    if (state.arePositionsEmpty(absPositions)) {
      newAbsRefPosition = absRefPosition + dir.toPosition;
    }
    state.copyWith(activeShapePosition: newAbsRefPosition);
  }

  ///Rotates the Shape in a Certain Direction
  void rotateShape(Rotation rotation) {
    final shape = state.activeShape;
    final absRefPosition = state.activeShapePosition;
    if (shape == null || absRefPosition == null) return;
    final absPositions =
        shape.absPositions(base: absRefPosition.toPosition, rotation: rotation);
    if (state.arePositionsEmpty(absPositions)) {
      shape.rotate(rotation);
    }
    state.copyWith(activeShape: shape);
  }

  /*--------------------------------------------------------------------------*/
  /* State getters                                                            */
  /*--------------------------------------------------------------------------*/

  /// Get the shape at a certain position (x,y)
  /// Returns null if no shape is presen
  Shape? getShapeAt(int x, int y) => state.grid[Position(x, y)];

  /// Get color of shape at a certain position (x,y)
  /// Returns null if no shape is presen
  Color? getShapeColor(int x, int y) {
    var color = getShapeAt(x, y)?.color;
    final activeShape = state.activeShape;
    final absRefPosition = state.activeShapePosition;
    if (activeShape == null || absRefPosition == null) {
      return color;
    }
    final absPositions =
        activeShape.absPositions(base: absRefPosition.toPosition);
    for (var pos in absPositions) {
      if (pos == Position(x, y)) color = activeShape.color;
    }
    return color;
  }

  /*--------------------------------------------------------------------------*/
  /* Functions                                                                */
  /*--------------------------------------------------------------------------*/

  /// Clears One Row and moves all above one row down.
  void clearFullRow(int row) {
    final newGrid = <Position, Shape?>{};
    state.grid.forEach((pos, shape) {
      if (shape != null) {
        if (pos.y < row) {
          newGrid[pos] = shape;
        } else if (pos.y > row) {
          newGrid[Position(pos.x, pos.y - 1)] = shape;
        }
      }
    });
    state = state.copyWith(grid: newGrid);
  }

  /// Clears all full Rows
  void clearFullRows() {
    final fullRows = state.whichRowsAreFull();
    // ignore: cascade_invocations
    fullRows.sort((a, b) => b.compareTo(a));
    for (var row in fullRows) {
      clearFullRow(row);
    }
  }
}
