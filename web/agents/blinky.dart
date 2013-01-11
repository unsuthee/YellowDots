
part of YellowDots;

class Blinky extends Agent
{
  
  Blinky({ Environment env, 
                Box2D box, 
                int direction:DEF.WEST,
                int speed:2
              }): super("Blinky",env:env,box:box,direction:direction,speed:speed)
  {
  }
  
  List get scaredTarget => [26,0];
  List get bornTarget => [14,14];     
  num get trapDuration => 2000;
  
  String getAnimationData()
  {
    // Blinky
    String data = '''
    {
      "MOVE_UP": {
        "sprites": [[0,12],[1,12]]
      },
      "MOVE_DOWN": {
        "sprites": [[4,12],[5,12]]
      },
      "MOVE_LEFT": {
        "sprites": [[2,12],[3,12]]
      },
      "MOVE_RIGHT": {
        "sprites": [[6,12],[7,12]]
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
    _state = Agent.STATE_MOVING;
  }
  
  List computeTargetPos()
  {
    // get Pacman position
    int tx = env().pacman.tilex;
    int ty = env().pacman.tiley;
   
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
  
  void handleCollision()
  {
  }
  
  String getThemeColor()
  {
    return "#ff0000";
  }
  
  void draw(CanvasRenderingContext2D ctx)
  {
    if (!_visible)
      return;
    
    super.draw(ctx);
    //drawTargetPosition(ctx);
  }
}
