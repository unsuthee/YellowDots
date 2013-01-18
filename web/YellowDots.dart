////////////////////////////////////////////////////////////////////////////////////////////////////
// YellowDots
// Author: UnSuthee
////////////////////////////////////////////////////////////////////////////////////////////////////

library YellowDots;

import 'dart:html';
import 'dart:json';
import 'dart:math';

part 'definition.dart';
part 'box.dart';
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
  
  // animation frame
  num renderTime;
  double fpsAverage;
  
  // background canvas
  bool _isBackgroundDirty;
  var _removedDots;
  bool _requestGameover;
  bool _requestCompleteLevel;
  
  // Game State
  static const int GAMESTATE_IDLE = 0;
  static const int GAMESTATE_PLAYING = 2;
  static const int GAMESTATE_OVER = 3;
  
  int _currentGameState = GAMESTATE_IDLE;  
  num _currentPauseDuration = 0;
  
  PacmanGame() 
  {
    canvas = query("#canvas");
    canvasCtx = canvas.context2d;
    
    bgCanvas = query("#bg_canvas");
    bgCanvasCtx = bgCanvas.context2d;
    bgCanvasCtx.font = "bold 16px Arial";
    
    window.on.keyDown.add(keyboardDownHandler, false);
    window.on.keyUp.add(keyboardUpHandler, false);
    window.requestAnimationFrame(tick);
    
    query('#start_btn').on.click.add((e) {
      startNewGame();
    });
    
    _currentGameState = GAMESTATE_OVER;

    imgCache = new ImageCache();
    layout = new Layout();

    setupData();
    bgCanvasCtx.fillStyle = "#fff";
    bgCanvasCtx.fillText("Press the start button!", 155, 300);
  }
  
  void setupData()
  {
    scoreboard = new Scoreboard();
    
    env = new Environment(this, layout);
    
    maze = new Maze();
    maze.initWallData(layout.currentLayout());
    maze.initDotCapsuleData(layout.currentLayout());
    
    scoreboard.drawScore();
    scoreboard.drawLevel();
    
    _removedDots = new List<List<int>>();
    _isBackgroundDirty = false;
    _requestGameover = false;
    _requestCompleteLevel = false;
    
    redrawBackground();
  }
  
  void startNewGame()
  {
    if (_currentGameState == GAMESTATE_OVER)
    {
      _currentGameState = GAMESTATE_PLAYING;
      setupData();
      window.requestAnimationFrame(tick);
    }
  }
  
  void dirtyBackground()
  {
    _isBackgroundDirty = true;
  }
  
  void addRemovedDots({int row, int col})
  {
    _removedDots.add([col,row]);
  }
  
  void pauseGame(num duration)
  {
    _currentPauseDuration = duration;
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
  
  void setGameover()
  {
    _requestGameover = true;
  }
  
  void requestCompleteLevel()
  {
    _requestCompleteLevel = true;
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
    
    if (_requestGameover)
    {
      _currentGameState = GAMESTATE_OVER;
      bgCanvasCtx.fillStyle = "#fff";
      bgCanvasCtx.fillText("Gameover", 200, 300);
      _requestGameover = false;
      return;
    }
    
    if (_requestCompleteLevel)
    {
      bgCanvasCtx.fillStyle = "#fff";
      bgCanvasCtx.fillText("Level Complete", 180, 300);
      _requestCompleteLevel = false;
      
      int currentLevel = scoreboard.level;
      int currentScore = scoreboard.score;
      int currentLives = scoreboard.lives;
      setupData();
      scoreboard.score = currentScore + 1;
      scoreboard.lives = currentLives;
      scoreboard.level = currentLevel;
      
      if (currentLevel > 2)
      {
        env.blinky.speed = 3;
        env.pinky.speed = 3;
        env.inky.speed = 3;
        env.pokey.speed = 3;
      }
      
      scoreboard.drawScore();
      scoreboard.drawLevel();
      redrawBackground();
      
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      env.update(delta);
      env.draw(ctx);
      
      pauseGame(3000); // pause game for 3 seconds
      return;
    }
    
    if (_currentPauseDuration > 0)
    {
      _currentPauseDuration -= delta;
      return;
    }
    
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    env.update(delta);
    env.draw(ctx);
  }
  
  void keyboardDownHandler(KeyboardEvent e)
  {
    switch (e.keyCode)
    {
      case 37: // left
        env.pacman.MoveBegin(DEF.WEST);
        break;
      case 38: // up
        env.pacman.MoveBegin(DEF.NORTH);
        break;
      case 39: // right
        env.pacman.MoveBegin(DEF.EAST);
        break;
      case 40: // down
        env.pacman.MoveBegin(DEF.SOUTH);
        break;
    }
  }
  
  void keyboardUpHandler(KeyboardEvent e)
  {
    switch (e.keyCode)
    {
      case 37: // left
        env.pacman.MoveEnd(DEF.WEST);
        break;
      case 38: // up
        env.pacman.MoveEnd(DEF.NORTH);
        break;
      case 39: // right
        env.pacman.MoveEnd(DEF.EAST);
        break;
      case 40: // down
        env.pacman.MoveEnd(DEF.SOUTH);
        break;
    }
  }
}
