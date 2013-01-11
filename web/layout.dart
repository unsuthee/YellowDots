part of YellowDots;

class Layout 
{
  var _currentLayout;
  
  var capsuleLookup = [];
  var agentPos = {};
  
  Layout()
  {
    _currentLayout = MAZE_ORIGINAL; //TINY_MAZE;
    init();
  }
  
  int layoutWidth()  => _currentLayout.length;
  int layoutHeight() => _currentLayout[0].length;
  List<String> currentLayout() => _currentLayout;
  
  void init()
  {
    for(int i=0; i<_currentLayout.length; i++)
    {
      for(int j=0; j<_currentLayout[i].length; j++)
      {
        //String pos = "${i}:${j}";
        var pos = [j,i];
        switch(_currentLayout[i][j])
        {
          case CAPSULE:
            capsuleLookup.add(pos);
            break;
          case PACMAN:
            agentPos["Pacman"] = pos;
            break;
          case PINKY:
            agentPos["Pinky"] = pos;
            break;
          case BLINKY:
            agentPos["Blinky"] = pos;
            break;
          case INKY:
            agentPos["Inky"] = pos;
            break;
          case POKEY:
            agentPos["Pokey"] = pos;
            break;
          default:
            break;
        }
      }
    }
  }

  static const SPACE    = '-';
  static const DOT      = '.';
  static const CAPSULE  = 'o';
  static const PACMAN   = 'P';
  static const PINKY    = 'k';
  static const BLINKY   = 'b';
  static const INKY     = 'i';
  static const POKEY    = 'c';
   
  // 28 x 33 ( col x row ) = 224 x 264 ( pixels )
  static const MAZE_ORIGINAL = 
                        const ["xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
                               "x@^^^^^^^^^^^^@@^^^^^^^^^^^^@x",
                               "x<............##............>x",
                               "x<.####.#####.##.#####.####.>x",
                               "x<o####.#####.##.#####.####o>x",
                               "x<.####.#####.##.#####.####.>x",
                               "x<..........................>x",
                               "x<.####.##.########.##.####.>x",
                               "x<.####.##.########.##.####.>x",
                               "x<......##....##....##......>x",
                               "x@vvvv#.#####-##-#####.#vvvv@x",
                               "x-----<.#####-##-#####.>-----x",
                               "x-----<.##----b-----##.>-----x",
                               "x-----<.##-+vJ==Lv+-##.>-----x",
                               "x^^^^^#.##->------<-##.#^^^^^x",
                               "x------.--->i-k-c-<---.------x",
                               "xvvvvv#.##->------<-##.#vvvvvx",
                               "x-----<.##-+^^^^^^+-##.>-----x",
                               "x-----<.##----------##.>-----x",
                               "x-----<.##-########-##.>-----x",
                               "x@^^^^#.##-########-##.#^^^^@x",
                               "x<............##............>x",
                               "x<.####.#####.##.#####.####.>x",
                               "x<.####.#####.##.#####.####.>x",
                               "x<o..##.......P-.......##..o>x",
                               "x@##.##.##.########.##.##.##@x",
                               "x@##.##.##.########.##.##.##@x",
                               "x<......##....##....##......>x",
                               "x<.##########.##.##########.>x",
                               "x<.##########.##.##########.>x",
                               "x<..........................>x",
                               "x@vvvvvvvvvvvvvvvvvvvvvvvvvv@x",
                               "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"];                              
}
