part of YellowDots;

class Scoreboard 
{
  int _totalScore;
  int _lives;
  int _currentLevel;
  
  int get score => _totalScore;
  int get lives => _lives;
  int get level => _currentLevel;
  
  set score(int s) => _totalScore = s;
  set lives(int l) => _lives = l;
  set level(int l) => _currentLevel = l;
  
  static const int DOT_SCORE = 10;
  static const int CAPSULE_SCORE = 100;
  static const int GHOST_SCORE = 200;
  
  Scoreboard()
  {
    reset();
  }
  
  void reset()
  {
    _totalScore = 0;
    _lives = 3;
    _currentLevel = 1;
  }
  
  void incLevel(int lv)
  {
    _currentLevel += lv;
  }
  
  void incScore(int score)
  {
    _totalScore += score;  
  }
  
  void incLifeCount(int delta)
  {
    _lives += delta;
  }
  
  void drawScore()
  {
    query("#score").text = "Score : ${_totalScore}";
  }
  
  void drawLevel()
  {
    query("#level").text = "Level : ${_currentLevel}";
  }
  
  void drawLifeCount(CanvasRenderingContext2D ctx, int size)
  {
    int sx = 0 * 17 + 1;
    int sy = 8 * 17 + 1;
    
    ImageCache imgCache = new ImageCache();
    
    int dy = 33 * size;
    int dx = 2  * size;
    for (var i=0; i < _lives; i++)
    {
      ctx.drawImage(imgCache.GetImageBuffer(),
                    sx,
                    sy,
                    16,
                    16,
                    dx - (size >> 1),
                    dy - (size >> 1),
                    size,
                    size);
      
      dx += size;
    }
    
  }
  
}
