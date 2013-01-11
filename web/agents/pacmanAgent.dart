part of YellowDots;

class PacmanAgent extends Agent
{
  
  PacmanAgent({ Environment env, 
                Box2D box, 
                int direction:DEF.NORTH,
                int speed:3 
              }): super("Pacman",env:env,box:box,direction:direction,speed:speed)
  {
    nextAction = DEF.NO_DIRECTION;
  }
  
  num frightenTime = 0;
  static const num earlyFrightenTimePeriod = 3000; // in ms
  static const num finalFrightenTimePeriod = 3000; // ms
  
  List get bornTarget => [14,24];  
  num get trapDuration => 2000;

  int nextAction; // a direction
  
  String getAnimationData()
  {
    // Pacman
    String data = '''
    {
      "MOVE_UP": {
        "sprites": [[1,8],[5,8]]
      },
      "MOVE_DOWN": {
        "sprites": [[3,8],[7,8]]
      },
      "MOVE_LEFT": {
        "sprites": [[0,8],[4,8]]
      },
      "MOVE_RIGHT": {
        "sprites": [[2,8],[6,8]]
      },
      "KO": {
        "sprites": [[0,14],[1,14],[2,14],[3,14],[4,14],[5,14],[6,14],[7,14],[0,15],[1,15]],
        "loop": "false",
        "default_duration": 200
      }   
    }
    ''';
    return data;
  }
 
  void onGhostEaten()
  {
    print("Pacman eat ghost");
  }
  
  void onPacmanEaten(Agent eater)
  {
    _state = Agent.STATE_KO;
    String animId = getAnimationIdByDirection(direction);
    assert(animId != null);
    _currAnimation = _animationSet[animId];
  }
  
  void onGameRestart()
  {
    _state = Agent.STATE_MOVING;
  }
  
  void OnCapsuleTaken()
  {
    frightenTime = earlyFrightenTimePeriod;
    _substate = Agent.SUB_STATE_FRIGHTEN_1;
  }
  
  void OnFrightenTimeEnd()
  {
    switch (_substate)
    {
      case Agent.SUB_STATE_FRIGHTEN_1:
        _substate = Agent.SUB_STATE_FRIGHTEN_2;
        frightenTime = finalFrightenTimePeriod;
        break;

      case Agent.SUB_STATE_FRIGHTEN_2:
        _substate = Agent.SUB_STATE_NORMAL;
        break;
    }
  }
 
  void MoveBegin(int direction)
  {
    switch (_state)
    {
      case Agent.STATE_IDLE:
      {
        String animId = getAnimationIdByDirection(direction);
        assert(animId != null);

        _currAnimation = _animationSet[animId];
        _currentDirection = direction;
        nextAction = DEF.NO_DIRECTION;
        
        switch (_state)
        {
          case Agent.STATE_IDLE:
            _state = Agent.STATE_MOVING;
            break;
        }
      }
      break;
        
      case Agent.STATE_MOVING:
      {
        int tx = tilex;
        int ty = tiley;
        var pos;
        switch (direction)
        {
          case DEF.NORTH:
            pos = [tx,ty-1];
            break;
          case DEF.SOUTH:
            pos = [tx,ty+1];
            break;
          case DEF.EAST:
            pos = [tx+1,ty];
            break;
          case DEF.WEST:
            pos = [tx-1,ty];
            break;
        }
        Maze maze = new Maze();
        if (!maze.hasWall(row:pos[1], col:pos[0]) &&
            !maze.isFrontGateArea(row:ty, col:tx))
        {
          String animId = getAnimationIdByDirection(direction);
          assert(animId != null);

          _currAnimation = _animationSet[animId];
          _currentDirection = direction;
          nextAction = DEF.NO_DIRECTION;
        }
        else
        {
          nextAction = direction;
        }
      }
      break;
    }
  }
  
  void MoveEnd(int direction)
  {
    
  }
  
  List computeTargetPos()
  {
    return null;  
  }
  
  String getAnimationIdByDirection(int direction)
  {
    switch (_state)
    {
      case Agent.STATE_IDLE:
      case Agent.STATE_MOVING:
      case Agent.STATE_TRAP:
        switch (direction)
        {
          case DEF.NORTH:
            return "MOVE_UP";
          case DEF.SOUTH:
            return "MOVE_DOWN";
          case DEF.EAST:
            return "MOVE_RIGHT";
          case DEF.WEST:
            return "MOVE_LEFT";
          default:
            return null;
        }
        break;
      case Agent.STATE_KO:
        return "KO";
    }
    return null;
  }
  
  void onEnterNewTile() 
  {
    //print("Enter new tile ${tilex}:${tiley}");
    bool warp = performWarp();
    
    if (nextAction != DEF.NO_DIRECTION)
    {
      int tx = tilex;
      int ty = tiley;
      var pos = [[DEF.NORTH,tx,ty-1], [DEF.SOUTH,tx,ty+1],
                 [DEF.EAST,tx+1,ty], [DEF.WEST,tx-1,ty]];
      
      Maze maze = new Maze();
      if (maze.isFrontGateArea(row:ty, col:tx))
      {
        return;
      }
      
      var newpos = pos.filter((l) => !maze.hasWall(row:l[2], col:l[1]));   

      if (newpos.length > 2)
      {
        // this is a junction
        for (final p in newpos)
        {
          if (p[0] == nextAction)
          {
            String animId = getAnimationIdByDirection(nextAction);
            assert(animId != null);

            _currAnimation = _animationSet[animId];
            _currentDirection = nextAction;
            nextAction = DEF.NO_DIRECTION;
            break;
          }
        }
      }
    }
  }
  
  void update(num delta)
  {    
    switch (_state)
    {
      case Agent.STATE_KO:
      {
        if (_currAnimation != null)
        {
          if (!_currAnimation.isCompleted())
          {
            _currAnimation.update(delta);
          }
          else 
          {
            env.restartGame();
          }
        }
      }
      break;
        
      case Agent.STATE_MOVING:
      case Agent.STATE_SCATTER:
      case Agent.STATE_TRAP:
      {
        if (_currAnimation != null)
        {
          _currAnimation.update(delta);
        }
        
        handleCollision();
        
        var savedPos = [box.cx,box.cy];
        var savedTile = [tilex,tiley];
        
        switch(_currentDirection)
        {
          case DEF.NORTH:
            box.cy -= _currentSpeed;
            alignToVerticalAxis();
            break;
          case DEF.SOUTH:
            box.cy += _currentSpeed;
            alignToVerticalAxis();
            break;
          case DEF.EAST:
            box.cx += _currentSpeed;
            alignToHorizontalAxis();
            break;
          case DEF.WEST:
            box.cx -= _currentSpeed;
            alignToHorizontalAxis();
            break;
        }
        
        if (hasCollideToWall())
        {
          box.cx = savedPos[0];
          box.cy = savedPos[1];
          onCollideWall();
        }
        else
        {
          if (tilex != savedTile[0] || 
              tiley != savedTile[1]) 
          {
            onEnterNewTile();
          }
        }
      }
      break;
    }
    
    if (frightenTime > 0)
    {
      frightenTime -= delta;
      if (frightenTime <= 0)
      {
        env.requestFrightenTimeEnd();
      }
    }
  }
  
  void draw(CanvasRenderingContext2D ctx)
  {
    if (_currAnimation != null)
    {
      Sprite sprite = _currAnimation.GetCurrentSprite();
      if (sprite != null)
      {
        sprite.draw(context:ctx, dx:_box.cx, dy:_box.cy, size:DEF.SIZE_AGENT);  
      }
    }
  }
  
  void onCollideWall()
  {
    switch (_state)
    {
      case Agent.STATE_MOVING:
        _state = Agent.STATE_IDLE;
        break;
    }
  }
  
  String getThemeColor()
  {
    return "#00ffff";
  }
  
  void handleCollision()
  {
  }
}
