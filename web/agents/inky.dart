part of YellowDots;

class Inky extends Agent
{
  
  Inky({ Environment env, 
                Box2D box, 
                int direction:DEF.NORTH,
                int speed:2 
              }): super("Inky",env:env,box:box,direction:direction,speed:speed)
  {
  }
  
  List get scaredTarget => [28,32];
  List get bornTarget => [14,14]; 
  num get trapDuration => 4000;

  String getAnimationData()
  {
    // Inky
    String data = '''
    {
      "MOVE_UP": {
        "sprites": [[0,11],[1,11]]
      },
      "MOVE_DOWN": {
        "sprites": [[4,11],[5,11]]
      },
      "MOVE_LEFT": {
        "sprites": [[2,11],[3,11]]
      },
      "MOVE_RIGHT": {
        "sprites": [[6,11],[7,11]]
      },
      "SCARED_1": {
        "sprites": [[0,13],[1,13]]
      },
      "SCARED_2": {
        "sprites": [[0,13],[2,13],[1,13],[3,13]]
      },
      "SCATTER_UP": {
        "sprites": [[7,13]]
      },
      "SCATTER_DOWN": {
        "sprites": [[5,13]]
      },
      "SCATTER_LEFT": {
        "sprites": [[4,13]]
      },
      "SCATTER_RIGHT": {
        "sprites": [[6,13]]
      }
    }
    ''';
    return data;
  }
       
  void onGameRestart()
  {
    _state = Agent.STATE_TRAP;
  }
  
  List computeTargetPos()
  {
    int px = env().pacman.tilex;
    int py = env().pacman.tiley;
    switch (env().pacman.direction)
    {
      case DEF.NORTH:
        py = py - 2;
        break;
      case DEF.SOUTH:
        py = py + 2;
        break;
      case DEF.EAST:
        px = px + 2;
        break;
      case DEF.WEST:
        px = px - 2;
        break;
    }
    // get Blinky's position
    int bx = env().blinky.tilex;
    int by = env().blinky.tiley;
    // get a target vector
    int tx = bx + (px - bx) * 2;
    int ty = by + (py - by) * 2;
    
    switch (_state)
    {
      case Agent.STATE_SCATTER:
        tx = scaredTarget[0];
        ty = scaredTarget[1];
        break;
      case Agent.STATE_KO:
        tx = bornTarget[0];
        ty = bornTarget[1];
        break;
    } 
    return [tx,ty];
  }
  
  String getThemeColor()
  {
    return "#eee";
  }
  
  void handleCollision()
  {
  }
  
  void draw(CanvasRenderingContext2D ctx)
  {
    if (!_visible)
      return;
    
    super.draw(ctx);
    //drawTargetPosition(ctx);
  }
}

