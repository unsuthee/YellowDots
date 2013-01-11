part of YellowDots;

class DEF {
  static const int NO_DIRECTION = 0;
  static const int NORTH = 1;
  static const int SOUTH = 2;
  static const int EAST  = 3;
  static const int WEST  = 4;
  
  static const int SIZE_BLOCK = 16;
  static const int SIZE_HALF_BLOCK = SIZE_BLOCK >> 1;
  static const int SIZE_DOT = 6;
  static const int SIZE_CAPSULE = 10;
  static const int SIZE_AGENT = SIZE_BLOCK * 2;
  
  static int OppositeDirection(int direction)
  {
    switch (direction)
    {
      case NORTH:
        return SOUTH;
      case SOUTH:
        return NORTH;
      case EAST:
        return WEST;
      case WEST:
        return EAST;
      default:
        return NO_DIRECTION;
    }
  }
  
  static int StringToDirection(String directionStr)
  {
    switch (directionStr)
    {
      case "NORTH":
        return DEF.NORTH;
      case "SOUTH":
        return DEF.SOUTH;
      case "EAST":
        return DEF.EAST;
      case "WEST":
        return DEF.WEST;
      default:
        return DEF.NO_DIRECTION;
    }
  }
  
  static int Distance(int sx, int sy, int dx, int dy)
  {
    return (sx-dx)*(sx-dx) + (sy-dy)*(sy-dy);
  }
}
