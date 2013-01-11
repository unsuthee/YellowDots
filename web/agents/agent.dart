part of YellowDots;

/**
 * TODO: Need to remove Frighten State 
 * 
 * 
 **/

abstract class Agent extends GameObject
{
  String _name;
  var _animationSet = null;
  var _currAnimation = null;
  
  int _state;
  int _substate;
  int _currentDirection;
  int _currentSpeed;
  
  List _targetTile = [];
  int _nextDirection;
  
  bool _visible;
  
  num trapCounter = 0;
  
  String get name => _name;
  List get bornTarget;
  num get trapDuration;
  
  Direction _currDirection = null;
  
  Agent(  name,
        { 
          Environment env, 
          Box2D box, 
          int direction:DEF.NORTH,
          int speed:3 
        }): super(env,box)
  {
    _name = name;
    _currentDirection = direction;
    _currentSpeed = speed;
    
    _state = STATE_TRAP; //STATE_MOVING;
    _substate = SUB_STATE_NORMAL;
    trapCounter = trapDuration;

    _animationSet = new HashMap<String,Animation>();
    setupAnimation();
    assert(_animationSet != null);
    
    String animId = getAnimationIdByDirection(direction);
    assert(animId != null);
    _currAnimation = _animationSet[animId];
    assert(_currAnimation != null);
    
    _visible = true;
  }

  // @override this method
  String getAnimationData();
  
  // override this method
  String getThemeColor();
  
  void onGameRestart();
  
  void onGhostEaten()
  {
    _state = STATE_KO;
  }
  
  void onPacmanEaten(Agent eater)
  {
    _visible = false;
  }
  
  bool performSpawning()
  {
    bool spawn = false;
    if (_state == STATE_KO)
    {
      if (tilex == bornTarget[0] && tiley == bornTarget[1])
      {
        _state = STATE_TRAP;
        trapCounter = trapDuration;
        spawn = true;
      }
    }
    return spawn;
  }
  
  List calcNextTilePosition()
  {
    int tx = tilex;
    int ty = tiley;
    var pos = [[DEF.NORTH,tx,ty-1], [DEF.SOUTH,tx,ty+1],
               [DEF.EAST,tx+1,ty], [DEF.WEST,tx-1,ty]];

    Maze maze = new Maze();
    var newPos;
    
    if (_state == STATE_KO)
    {
      int oppositeDir = DEF.OppositeDirection(_currentDirection);
      newPos = pos.filter((l) => (!maze.hasWall(row:l[2],col:l[1]) && l[0] != oppositeDir));
      return newPos;
    }
    
    if (_state == STATE_TRAP)
    {      
      if (maze.isTrapZone(row:ty,col:tx))
      {
        String key = "${tx}:${ty}";
        newPos = pos.filter((l)=> l[0] == maze.trapZone[key]);
      } 
      else if (maze.isSpecialZone(row:ty,col:tx))
      {
        String key = "${tx}:${ty}";
        newPos = pos.filter((l)=> l[0] == maze.specialZone[key]);
      }
      else
      {
        assert(false);
      }
      return newPos;
    }
    
    if (maze.isSpecialZone(row:ty,col:tx))
    {
      String key = "${tx}:${ty}";
      newPos = pos.filter((l)=> l[0] == maze.specialZone[key]);
      return newPos;
    }
    
    if (maze.isFrontGateArea(row:ty, col:tx))
    {
      if (direction == DEF.EAST || direction == DEF.WEST)
      {
        return pos.filter((l)=> l[0] == direction);
      }
      else
      {
        return pos.filter((l)=> l[0] == DEF.EAST || l[0] == DEF.WEST);
      }
    }

    if (_substate == SUB_STATE_FRIGHTEN_1 || _substate == SUB_STATE_FRIGHTEN_2)
    {
      int oppositeDir = DEF.OppositeDirection(_currentDirection);
      newPos = pos.filter((l) => (!maze.hasWall(row:l[2],col:l[1]) && l[0] != oppositeDir));
      // just return one randomly action
      assert(newPos.length > 0);
      
      if (newPos.length == 1)
      {
        return newPos;
      }
      
      var rng = new Random();
      int index = rng.nextInt(newPos.length-1);
      var dir = newPos[index][0];
      return newPos.filter((l) => l[0] == dir);
    }
    
    int oppositeDir = DEF.OppositeDirection(_currentDirection);
    newPos = pos.filter((l) => (!maze.hasWall(row:l[2],col:l[1]) && l[0] != oppositeDir));
    return newPos;
  }
  
  // @override this method
  void onEnterNewTile()
  {
    if (performWarp())
      return;
    
    if (performSpawning())
      return;
    
    List positions = calcNextTilePosition();
    if (positions.length == 1)
    {
      _currentDirection = positions[0][0];
    }
    else
    {
      List targetPos = computeTargetPos();
      _targetTile = [targetPos[0],targetPos[1]];
      int min_distance = 10000;
      int newDirection = _currentDirection;
      for (final pos in positions)
      {
        int distance = DEF.Distance(targetPos[0],targetPos[1],pos[1],pos[2]);
        if (distance < min_distance)
        {
          min_distance = distance;
          newDirection = pos[0];
        }
      }
      _currentDirection = newDirection;
    }
    String animId = getAnimationIdByDirection(direction);
    assert(animId != null);
    _currAnimation = _animationSet[animId];
  }
  
  // @override this method
  void onCollideWall()
  {
  }
  
  
  List computeTargetPos();
  
  bool performWarp()
  {
    bool warp = false;
    if (tilex == 0 && tiley == 15)
    {
      box().cx = 28 * DEF.SIZE_BLOCK + DEF.SIZE_HALF_BLOCK;
      warp = true;
    }
    else if (tilex == 29 && tiley == 15)
    {
      box().cx = 1 * DEF.SIZE_BLOCK + DEF.SIZE_HALF_BLOCK;
      warp = true;
    }
    return warp;
  }
  
  void OnForceScatter()
  {
    if (_state == STATE_MOVING)
    {
      _state = STATE_SCATTER;   
      //int oppositeDir = DEF.OppositeDirection(_currentDirection);
      //_currentDirection = oppositeDir;
    }
  }
  
  void OnForceChase()
  {
    if (_state == STATE_SCATTER)
    {
      _state = STATE_MOVING;   
      //int oppositeDir = DEF.OppositeDirection(_currentDirection);
      //_currentDirection = oppositeDir;
    }
  }
  
  void OnCapsuleTaken()
  {
    if (_state != STATE_KO)
    {
      _substate = SUB_STATE_FRIGHTEN_1;
      String animId = getAnimationIdByDirection(direction);
      assert(animId != null);
      _currAnimation = _animationSet[animId];
    }
  }
  
  void OnFrightenTimeEnd()
  {
    switch (_substate)
    {
      case SUB_STATE_FRIGHTEN_1:
        _substate = SUB_STATE_FRIGHTEN_2;
        break;
      case SUB_STATE_FRIGHTEN_2:
        _substate = SUB_STATE_NORMAL;
        break;
    }
    String animId = getAnimationIdByDirection(direction);
    assert(animId != null);
    _currAnimation = _animationSet[animId];
  }
  
  bool isEatable()
  {
    return (_substate != SUB_STATE_NORMAL);
  }
  
  static const int STATE_IDLE = 1;
  static const int STATE_MOVING = 2;
  static const int STATE_SCATTER = 3;
  static const int STATE_KO = 6;
  // for ghost
  static const int STATE_TRAP  = 12;
  
  // substate
  static const int SUB_STATE_NORMAL     = 100;
  static const int SUB_STATE_FRIGHTEN_1 = 101;
  static const int SUB_STATE_FRIGHTEN_2 = 102;
  static const int SUB_STATE_KO         = 103;
  
  String getAnimationIdByDirection(int direction)
  {
    switch (_state)
    {
      case STATE_IDLE:
      case STATE_MOVING:
      case STATE_SCATTER:
      case STATE_TRAP:
        switch(_substate)
        {
          case SUB_STATE_NORMAL:
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
          case SUB_STATE_FRIGHTEN_1:
            return "SCARED_1";
          case SUB_STATE_FRIGHTEN_2:
            return "SCARED_2";
        }
        break;
      case STATE_KO:
        switch (direction)
        {
          case DEF.NORTH:
            return "SCATTER_UP";
          case DEF.SOUTH:
            return "SCATTER_DOWN";
          case DEF.EAST:
            return "SCATTER_RIGHT";
          case DEF.WEST:
            return "SCATTER_LEFT";
          default:
            return null;
        }
        break;
    }
    return null;
  }
  
  void setupAnimation()
  {
    String jsonStr = getAnimationData();
    Map animData = JSON.parse(jsonStr);
    for (String animId in animData.keys)
    {
      Map animation = animData[animId];
      
      bool loop = true;
      if (animation.containsKey("loop"))
      {
        loop = (animation["loop"] == "true");
      }
      Animation anim = new Animation(name:animId,loopBack:loop);
      
      assert(animation.containsKey("sprites") == true);
      List sprites = animation["sprites"];
      for (List srcPos in sprites)
      {
        anim.AddSprite(new Sprite(sx:srcPos[0],sy:srcPos[1]), 100);
      }
      _animationSet[animId] = anim;
    }
  }
  
  void MoveBegin(int direction)
  {
    if (_state == STATE_IDLE ) 
    {
      String animId = getAnimationIdByDirection(direction);
      assert(animId != null);

      _currAnimation = _animationSet[animId];
      _currentDirection = direction;
      _state = STATE_MOVING;
    }
  }
  
  void MoveEnd(int direction)
  {
    if (_state == STATE_MOVING  )
    {
      _state = STATE_IDLE;
    }
  }
  
  void onCollide(GameObject other)
  {
    
  }
  
  bool hasCollideToWall()
  {
    Maze maze = new Maze();
    return maze.hasWall(row:tiley,col:tilex);
  }
  
  void handleCollision()
  {
  }
  
  int get tilex => box().cx ~/ DEF.SIZE_BLOCK;
  int get tiley => box().cy ~/ DEF.SIZE_BLOCK;
  int get direction => _currentDirection;
      
  int calcTileX()
  {
    switch (direction)
    {
      case DEF.NORTH:
        return box().cx ~/ DEF.SIZE_BLOCK;
      case DEF.SOUTH:
        return box().cx ~/ DEF.SIZE_BLOCK;
      case DEF.EAST:
        return (box().cx - DEF.SIZE_HALF_BLOCK) ~/ DEF.SIZE_BLOCK;
      case DEF.WEST:
        return (box().cx + DEF.SIZE_HALF_BLOCK) ~/ DEF.SIZE_BLOCK;
      default:
        return box().cx ~/ DEF.SIZE_BLOCK;
    }
  }
  
  int calcTileY()
  {
    switch (direction)
    {
      case DEF.NORTH:
        return (box().cy + DEF.SIZE_HALF_BLOCK) ~/ DEF.SIZE_BLOCK;
      case DEF.SOUTH:
        return (box().cy - DEF.SIZE_HALF_BLOCK) ~/ DEF.SIZE_BLOCK;
      case DEF.EAST:
        return box().cy ~/ DEF.SIZE_BLOCK;
      case DEF.WEST:
        return box().cy ~/ DEF.SIZE_BLOCK;
      default:
        return box().cy ~/ DEF.SIZE_BLOCK;
    }
  }
  
  void alignToVerticalAxis()
  {
    if (_state == STATE_TRAP)
      return;
    
    int centerPos = tilex * DEF.SIZE_BLOCK + DEF.SIZE_HALF_BLOCK;
    if (box().cx < centerPos)
    {
      box().cx++;
    }
    else if (box().cx > centerPos)
    {
      box().cx--;
    }
  }
  
  void alignToHorizontalAxis()
  {
    if (_state == STATE_TRAP)
      return;
    
    int centerPos = tiley * DEF.SIZE_BLOCK + DEF.SIZE_HALF_BLOCK;
    if (box().cy < centerPos)
    {
      box().cy++;
    }
    else if (box().cy > centerPos)
    {
      box().cy--;
    }
  }
  
  void update(num delta)
  {
    if (_currAnimation != null)
    {
      _currAnimation.update(delta);
    }
    
    switch (_state)
    {
      case STATE_MOVING:
      case STATE_SCATTER:
      case STATE_TRAP:
      case STATE_KO:
      {
        handleCollision();
        
        var savedPos = [box().cx,box().cy];
        var savedTile = [tilex,tiley];
        
        switch(_currentDirection)
        {
          case DEF.NORTH:
            box().cy -= _currentSpeed;
            alignToVerticalAxis();
            break;
          case DEF.SOUTH:
            box().cy += _currentSpeed;
            alignToVerticalAxis();
            break;
          case DEF.EAST:
            box().cx += _currentSpeed;
            alignToHorizontalAxis();
            break;
          case DEF.WEST:
            box().cx -= _currentSpeed;
            alignToHorizontalAxis();
            break;
        }
        
        if (hasCollideToWall())
        {
          box().cx = savedPos[0];
          box().cy = savedPos[1];
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
    
    if (trapCounter > 0)
    {
      trapCounter -= delta;
      if (trapCounter <= 0)
      {
        _state = STATE_MOVING;
      }
    }
  }
  
  void draw(CanvasRenderingContext2D ctx)
  {
    if (_currAnimation != null)
    {
      Sprite sprite = _currAnimation.GetCurrentSprite();
      sprite.draw(context:ctx, dx:_box.cx, dy:_box.cy, size:DEF.SIZE_AGENT);
    }
  }
  
  void drawTargetPosition(CanvasRenderingContext2D ctx)
  {
    if (_targetTile.length == 2)
    {
      ctx.strokeStyle = getThemeColor();
      ctx.beginPath();
      int bx = box().cx;
      int by = box().cy;
      ctx.moveTo(bx,by);
      int tx = _targetTile[0] * DEF.SIZE_BLOCK + DEF.SIZE_HALF_BLOCK;
      int ty = _targetTile[1] * DEF.SIZE_BLOCK + DEF.SIZE_HALF_BLOCK;
      ctx.lineTo(tx,ty);
      ctx.stroke();
    }
  }
}
