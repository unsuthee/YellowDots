part of YellowDots;

class Pinky extends Agent
{
  
  Pinky({ Environment env, 
                Box2D box, 
                int direction:DEF.NORTH,
                int speed:2 
              }): super("Pinky",env:env,box:box,direction:direction,speed:speed)
  {
  }
  
  List get scaredTarget => [3,0];
  List get bornTarget => [14,14]; 
  num get trapDuration => 3000;

  String getAnimationData()
  {
    // Pinky
    String data = '''
    {
      "MOVE_UP": {
        "sprites": [[0,10],[1,10]]
      },
      "MOVE_DOWN": {
        "sprites": [[4,10],[5,10]]
      },
      "MOVE_LEFT": {
        "sprites": [[2,10],[3,10]]
      },
      "MOVE_RIGHT": {
        "sprites": [[6,10],[7,10]]
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
    // get Pacman position
    int tx = env().pacman.tilex;
    int ty = env().pacman.tiley;
    switch (env().pacman.direction)
    {
      case DEF.NORTH:
        ty = ty - 4;
        break;
      case DEF.SOUTH:
        ty = ty + 4;
        break;
      case DEF.EAST:
        tx = tx + 4;
        break;
      case DEF.WEST:
        tx = tx - 4;
        break;
    }
    
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
    return "#ff99ff";
  }
  
  void draw(CanvasRenderingContext2D ctx)
  {
    if (!_visible)
      return;
    
    super.draw(ctx);
    //drawTargetPosition(ctx);
  }
}

