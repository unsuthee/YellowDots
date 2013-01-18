part of YellowDots;

class Maze 
{
  static final Maze _instance = new Maze._internal();
  
  static Map _walls = {};
  static Map _specialZone = {}; // key {tilex,tiley}->{Direction}
  static Map _trapZone = {}; // key {tilex,tiley}->{Direction}
  static Map _dots = {};
  
  Map get specialZone => _specialZone;
  Map get trapZone => _trapZone;
  
  factory Maze()
  {
    if (_specialZone.length == 0)
    {
      _instance.initSpecialZone();
      _instance.initTrapZone();
    }
    return _instance;
  }
  
  bool isSpecialZone({int row, int col})
  {
    String key = "${col}:${row}";
    return _specialZone.containsKey(key);
  }
    
  void initSpecialZone()
  {
    _specialZone["12:14"] = DEF.SOUTH;
    _specialZone["12:15"] = DEF.SOUTH;
    _specialZone["12:16"] = DEF.EAST;
    _specialZone["13:16"] = DEF.EAST;
    _specialZone["13:15"] = DEF.NORTH;
    _specialZone["13:14"] = DEF.WEST;
    
    _specialZone["14:14"] = DEF.NORTH;
    _specialZone["14:15"] = DEF.SOUTH;
    _specialZone["14:16"] = DEF.EAST;
    _specialZone["15:16"] = DEF.NORTH;
    _specialZone["15:15"] = DEF.NORTH;
    _specialZone["15:14"] = DEF.NORTH;
    
    _specialZone["16:14"] = DEF.WEST;
    _specialZone["16:15"] = DEF.SOUTH;
    _specialZone["16:16"] = DEF.EAST;
    _specialZone["17:16"] = DEF.NORTH;
    _specialZone["17:15"] = DEF.NORTH;
    _specialZone["17:14"] = DEF.WEST;
    
    // gates
    _specialZone["14:13"] = DEF.NORTH;
    _specialZone["15:13"] = DEF.NORTH;
  }
  
  bool isTrapZone({int row, int col})
  {
    String key = "${col}:${row}";
    return _trapZone.containsKey(key);
  }
  
  void initTrapZone()
  {
    _trapZone["13:16"] = DEF.NORTH;
    _trapZone["14:14"] = DEF.SOUTH;
    _trapZone["15:14"] = DEF.WEST;
    _trapZone["16:14"] = DEF.SOUTH;
  }
   
  bool isFrontGateArea({int row, int col})
  {
    return ((row == 12 && col == 14) || (row == 12 && col == 15));
  }
  
  static const int N  = 0x80;
  static const int NE = 0x40;
  static const int E  = 0x20;
  static const int SE = 0x10;
  static const int S  = 0x8;
  static const int SW = 0x4;
  static const int W  = 0x2;
  static const int NW = 0x1;
  
  bool isWall(String c)
  {
    return (c == '#' || c == '^' || c == 'v' || c == '<' ||
            c == '>' || c == '+' || c == '@' || c == 'J' ||
            c == 'L');
  }
  
  bool isPassable(String c)
  {
    return (c == '-' || c == '.' || c == 'o' ||
            c == 'P' || c == 'b' || c == 'i' ||
            c == 'k' || c == 'c' || c == '=');
  }
  
  // N,NE,E,SE,S,SW,W,NW
  int calcNeighbor(List<String> layoutString, {int row, int col})
  {
    int rval = 0;
    if (isWall(layoutString[row-1][col])) 
      rval |= N;
    if (isWall(layoutString[row-1][col+1])) 
      rval |= NE;
    if (isWall(layoutString[row][col+1])) 
      rval |= E;
    if (isWall(layoutString[row+1][col+1])) 
      rval |= SE;
    if (isWall(layoutString[row+1][col])) 
      rval |= S;
    if (isWall(layoutString[row+1][col-1])) 
      rval |= SW;
    if (isWall(layoutString[row][col-1])) 
      rval |= W;
    if (isWall(layoutString[row-1][col-1])) 
      rval |= NW;
  
    return rval;
  }

  static const NULL_EDGE = const [-1,-1];
  static const SGL_NW_CORNER = const [0,0];
  static const SGL_NE_CORNER = const [1,0];
  static const SGL_SW_CORNER = const [2,0];
  static const SGL_SE_CORNER = const [3,0];
  static const SGL_S_EDGE = const [1,3];
  static const SGL_N_EDGE = const [0,3];
  static const SGL_E_EDGE = const [2,3];
  static const SGL_W_EDGE = const [3,3];
  
  List<int> determineSingleBorderType(int neighbors)
  {
    switch(neighbors)
    {
      case 0x3E:
      case 0x3F:
      case 0x7E:
        return SGL_N_EDGE;
      case 0xA:
      case 0xE:
      case 0xFB:
        return SGL_NE_CORNER;
      case 0x8F:
      case 0x9F:
      case 0xCF:
        return SGL_E_EDGE;
      case 0x82:
      case 0x83:
      case 0xFE:
        return SGL_SE_CORNER;
      case 0xE3:
      case 0xF3:
      case 0xE7:
        return SGL_S_EDGE;
      case 0xA0:
      case 0xBF:
      case 0xE0:
        return SGL_SW_CORNER;
      case 0xF8:
      case 0xF9:
      case 0xFC:
        return SGL_W_EDGE;
      case 0x28:
      case 0x38:
      case 0xEF:
        return SGL_NW_CORNER;
      
      case 0xFF:
      default:
        return NULL_EDGE;
    }
  }
  
  List<int> determineRoundBorderType(int neighbors)
  {
    switch(neighbors)
    {
      case 0x28: // nw
        return [4,2];
      case 0xA:  // ne
        return [5,2];
      case 0xA0: // sw
        return [6,2];
      case 0x82: // se
        return [7,2];
      case 0xB8: // sw - vertical connector
        return [2,1];
      case 0xE8: // nw - vertical connector
        return [0,1];
      case 0x8B: // ne - vertical connector
        return [1,1];
      case 0x8E: // se - vertical connector
        return [3,1];
      case 0x3A: // ne - horz connector
        return [7,1];
      case 0x2E: // nw - horz connector
        return [6,1];
      default:
        return NULL_EDGE;
    }
  }
  
  List<int> determineSharpBorderType(int neighbors)
  {
    switch(neighbors)
    {
      case 0x28: // nw
        return [4,0];
      case 0xA:  // ne
        return [5,0];
      case 0xA0: // sw
        return [6,0];
      case 0x82: // se
        return [7,0];
      default:
        return NULL_EDGE;
    }
  }
  
  void initWallData(List<String> layoutString)
  {
    for(int r=1; r<layoutString.length-1; r++)
    {
      for(int c=1; c<layoutString[r].length-1; c++)
      {
        if (isWall(layoutString[r][c]))
        {
          String key = "${r}:${c}";
          _walls[key] = true;
        }
      }
    }
  }

  bool hasWall({int row, int col})
  {
    String key = "${row}:${col}";
    return _walls.containsKey(key);
  }
  
  void initDotCapsuleData(List<String> layoutString)
  {
    for(int r=1; r<layoutString.length-1; r++)
    {
      for(int c=1; c<layoutString[r].length-1; c++)
      {
        String key = "${r}:${c}";
        switch (layoutString[r][c])
        {
          case '.':
            _dots[key] = [c,r];
            break;
        }
      }
    }
  }
  
  int getDotCount()
  {
    return _dots.length;
  }
  
  // return true if item exists and is removed from the map
  bool removeDotIfExists({int row, int col})
  {
    String key = "${row}:${col}";
    if (_dots.containsKey(key))
    {
      _dots.remove(key);
      return true;
    }
    return false;
  }
  
  void drawBlackDot(CanvasRenderingContext2D ctx, {int row, int col})
  {
    int px = col * DEF.SIZE_BLOCK;
    int py = row * DEF.SIZE_BLOCK;
    ctx.fillStyle = "#000";
    ctx.fillRect(px, py, DEF.SIZE_BLOCK, DEF.SIZE_BLOCK);
  }
  
  void drawDot(CanvasRenderingContext2D ctx, int size)
  {
    ImageCache imgCache = new ImageCache();
    int sx = 3 * 17 + 1;
    int sy = 15 * 17 + 1;
    for (final pos in _dots.values)
    {
      int px = pos[0] * size + (size >> 1);
      int py = pos[1] * size + (size >> 1);
      ctx.drawImage(imgCache.GetImageBuffer(),
                    sx, sy, 16, 16,
                    px - (size >> 1),
                    py - (size >> 1),
                    size,
                    size);
    }
  }
  
  void drawGrid(CanvasRenderingContext2D ctx, List<String> layoutString, int size)
  {
    ctx.strokeStyle = "#fff";
    ctx.beginPath();
    for(int r=1; r<layoutString.length-1; r++)
    {
      ctx.moveTo(0, r * size);
      ctx.lineTo(480, r * size);
    }
    
    for(int c=1; c<layoutString[0].length-1; c++)
    {
      ctx.moveTo(c * size, 0);
      ctx.lineTo(c * size, 528);
    }
    ctx.stroke();
  }
  
  void drawMaze(CanvasRenderingContext2D ctx, List<String> layoutString, int size)
  {
    ImageCache imgCache = new ImageCache();
    
    for(int r=1; r<layoutString.length-1; r++)
    {
      for(int c=1; c<layoutString[r].length-1; c++)
      {
        int px = c * size + (size >> 1);
        int py = r * size + (size >> 1);
        int neighbors = calcNeighbor(layoutString, row:r, col:c);
        List<int> borderType;
        switch (layoutString[r][c])
        {
          case '#':
            borderType = determineSingleBorderType(neighbors);
            break;
          case '^':
            borderType = [2,2];
            break;
          case 'v':
            borderType = [0,2];
            break;
          case '<':
            borderType = [1,2];
            break;
          case '>':
            borderType = [3,2];
            break;
          case '+':
            borderType = determineSharpBorderType(neighbors);
            break;
          case '@':
            borderType = determineRoundBorderType(neighbors);
            break;
          case 'J':
            borderType = [4,3];
            break;
          case 'L':
            borderType = [5,3];
            break;
          case '=':
            borderType = [4,15];
            break;
          default:
            borderType = NULL_EDGE;
            break;
        }
        
        if (borderType != NULL_EDGE)
        {
          int sx = borderType[0] * 17 + 1;
          int sy = borderType[1] * 17 + 1;
          ctx.drawImage(imgCache.GetImageBuffer(),
                        sx, sy, 16, 16,
                        px - (size >> 1),
                        py - (size >> 1),
                        size,
                        size);
        }
      }
    }
    //drawGrid(ctx,layoutString,size);
  }
  
  Maze._internal();
}
