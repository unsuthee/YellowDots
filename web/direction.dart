part of YellowDots;

class Direction 
{
  int _x;
  int _y;
  int _type;
  
  int get x => _x;
  int get y => _y;
  int get type => _type;
  
  /////////////////////////////////////////////////////////////////////////////
  
  static const int NONE  = 0;
  static const int NORTH = 1;
  static const int EAST  = 2;
  static const int SOUTH = 3;
  static const int WEST  = 4;
  
  /////////////////////////////////////////////////////////////////////////////
  
  Direction()
  {
    _x = 0;
    _y = 0;
    _type = NONE;
  }
  
  Direction.North()
  {
    _x = 0;
    _y = -1;
    _type = NORTH;
  }
  
  Direction.South()
  {
    _x = 0;
    _y = 1;
    _type = SOUTH;
  }
  
  Direction.East()
  {
    _x = 1;
    _y = 0;
    _type = EAST;
  }
  
  Direction.West()
  {
    _x = -1;
    _y = 0;
    _type = WEST;
  }
  
  bool operator==(Direction other)
  {
    return (type == other.type);  
  }

  Direction reverse()
  {
    switch(_type)
    {
      case NORTH:
        return new Direction.South();
      case SOUTH:
        return new Direction.North();
      case EAST:
        return new Direction.West();
      case WEST:
        return new Direction.East();
      default:
        return new Direction();
    }
  }
  
  String toString()
  {
    switch(_type)
    {
      case NORTH:
        return "north";
      case SOUTH:
        return "south";
      case EAST:
        return "east";
      case WEST:
        return "west";
      default:
        return "none";
    }
  }
}
