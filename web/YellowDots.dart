library YellowDots;

import 'dart:html';
import 'dart:json';
import 'dart:math';

part 'definition.dart';
part 'box.dart';
part 'direction.dart';
part 'layout.dart';
part 'Environment.dart';
part 'agents/agent.dart';
part 'agents/pacmanAgent.dart';
part 'agents/blinky.dart';
part 'agents/pinky.dart';
part 'agents/inky.dart';
part 'agents/pokey.dart';
part 'capsule.dart';
part 'imageData.dart';
part 'maze.dart';
part 'animation.dart';
part 'sprite.dart';
part 'scoreboard.dart';

void main() 
{
  new PacmanGame();  
}

class PacmanGame
{
  CanvasElement canvas;
  CanvasRenderingContext2D canvasCtx;
  
  CanvasElement bgCanvas;
  CanvasRenderingContext2D bgCanvasCtx;
  
  Layout layout;
  Environment env;
  ImageCache imgCache;
  Maze maze;
  Scoreboard scoreboard;
  
  num renderTime;
  double fpsAverage;
  
  bool _isBackgroundDirty;
  var _removedDots;
  
  // Game State
  static const int GAMESTATE_IDLE = 0;
  static const int GAMESTATE_LOADING = 1;
  static const int GAMESTATE_PLAYING = 2;
  static const int GAMESTATE_OVER = 3;
  
  int _currentGameState = GAMESTATE_IDLE;
  
  PacmanGame() 
  {
    canvas = query("#canvas");
    canvasCtx = canvas.context2d;
    
    bgCanvas = query("#bg_canvas");
    bgCanvasCtx = bgCanvas.context2d;
    
    window.on.keyDown.add(keyboardDownHandler, false);
    window.on.keyUp.add(keyboardUpHandler, false);
    window.requestAnimationFrame(tick);
    
    _currentGameState = GAMESTATE_PLAYING;

    imgCache = new ImageCache();
    
    scoreboard = new Scoreboard();
    
    layout = new Layout();
    env = new Environment(this, layout);
    
    maze = new Maze();
    maze.initWallData(layout.currentLayout());
    maze.initDotCapsuleData(layout.currentLayout());
    redrawBackground();
    
    scoreboard.drawScore();
    scoreboard.drawLevel();
    
    _removedDots = new List<List<int>>();
    _isBackgroundDirty = false;
  }
  
  void dirtyBackground()
  {
    _isBackgroundDirty = true;
  }
  
  void addRemovedDots({int row, int col})
  {
    _removedDots.add([col,row]);
  }
  
  void redrawBackground()
  {
    bgCanvasCtx.clearRect(0, 0, bgCanvas.width, bgCanvas.height);
    maze.drawMaze(bgCanvasCtx, layout.currentLayout(), DEF.SIZE_BLOCK);
    maze.drawDot(bgCanvasCtx, DEF.SIZE_BLOCK);
    scoreboard.drawLifeCount(bgCanvasCtx, DEF.SIZE_BLOCK);
  }
  
  void tick(num time)
  {
    if (_currentGameState == GAMESTATE_PLAYING)
    {
      renderLoop(canvasCtx);
      window.requestAnimationFrame(tick);
    }
  }
  
  /**
   * Display the animation's FPS in a div.
   */
  void showFps(num fps) 
  {
    if (fpsAverage == null) 
    {
      fpsAverage = fps;
    }
    fpsAverage = fps * 0.05 + fpsAverage * 0.95;
    query("#notes").text = "${fpsAverage.round().toInt()} fps";
  }
  
  void renderLoop(CanvasRenderingContext2D ctx)
  {
    num delta = 0;
    num t = new Date.now().millisecondsSinceEpoch;
    if (renderTime != null) 
    {
      delta = (t - renderTime).round();
      showFps(1000 / delta);
    }
    renderTime = t;
    
    if (_isBackgroundDirty)
    {
      redrawBackground();
      _isBackgroundDirty = false;
    }
    else if (_removedDots.length > 0)
    {
      maze = new Maze();
      for (final pos in _removedDots)
      {
        maze.drawBlackDot(bgCanvasCtx,col:pos[0],row:pos[1]);
      }
      _removedDots.clear();
    }
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    env.update(delta);
    env.draw(ctx);
  }
  
  void keyboardDownHandler(KeyboardEvent e)
  {
    //print("CharCode is ${e.charCode}");
    //print("KeyCode is ${e.keyCode}");
    switch (e.keyCode)
    {
      case 37: // left
        //env.getGhostByIndex(0).MoveBegin(DEF.WEST);
        env.pacman.MoveBegin(DEF.WEST);
        break;
      case 38: // up
        //env.getGhostByIndex(0).MoveBegin(DEF.NORTH);
        env.pacman.MoveBegin(DEF.NORTH);
        break;
      case 39: // right
        //env.getGhostByIndex(0).MoveBegin(DEF.EAST);
        env.pacman.MoveBegin(DEF.EAST);
        break;
      case 40: // down
        //env.getGhostByIndex(0).MoveBegin(DEF.SOUTH);
        env.pacman.MoveBegin(DEF.SOUTH);
        break;
    }
  }
  
  void keyboardUpHandler(KeyboardEvent e)
  {
    switch (e.keyCode)
    {
      case 37: // left
        //env.getGhostByIndex(0).MoveEnd(DEF.WEST);
        env.pacman.MoveEnd(DEF.WEST);
        break;
      case 38: // up
        //env.getGhostByIndex(0).MoveEnd(DEF.NORTH);
        env.pacman.MoveEnd(DEF.NORTH);
        break;
      case 39: // right
        //env.getGhostByIndex(0).MoveEnd(DEF.EAST);
        env.pacman.MoveEnd(DEF.EAST);
        break;
      case 40: // down
        //env.getGhostByIndex(0).MoveEnd(DEF.SOUTH);
        env.pacman.MoveEnd(DEF.SOUTH);
        break;
      case 65:
        env.requestCapsuleTakenEvent();
        break;
    }
  }
}
