part of YellowDots;

class Pokey extends Agent
{
  
  Pokey({ Environment env, 
                Box2D box, 
                int direction:DEF.NORTH,
                int speed:2 
              }): super("Pokey",env:env,box:box,direction:direction,speed:speed)
  {
  }
  
  List get scaredTarget => [1,32];
  List get bornTarget => [16,14]; 
  num get trapDuration => 6000;

  String getAnimationData()
  {
    // Pokey
    String data = '''
    {
      "MOVE_UP": {
        "sprites": [[0,9],[1,9]]
      },
      "MOVE_DOWN": {
        "sprites": [[4,9],[5,9]]
      },
      "MOVE_LEFT": {
        "sprites": [[2,9],[3,9]]
      },
      "MOVE_RIGHT": {
        "sprites": [[6,9],[7,9]]
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
    //get Pacman's position
    int px = env().pacman.tilex;
    int py = env().pacman.tiley;
    int distance = DEF.Distance(px,py,tilex,tiley);
    // determine the target position
    int tx = (distance >= 64) ? px: scaredTarget[0];
    int ty = (distance >= 64) ? py: scaredTarget[1];
    
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
    return "#ffff00";
  }
  
  void draw(CanvasRenderingContext2D ctx)
  {
    if (!_visible)
      return;
    
    super.draw(ctx);
    //drawTargetPosition(ctx);
  }
}

