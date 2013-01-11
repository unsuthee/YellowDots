part of YellowDots;

class Animation 
{
  String _name;
  
  List<Sprite> _sprites = new List<Sprite>();
  List<int> _durations = new List<int>();
  
  int  _currentSpriteIndex;
  bool _isLoop;
  
  final int _animationFrameRate = 10; // frames
  int _counter = 0;
  
  String get name => _name;
  
  bool isCompleted() => (_currentSpriteIndex > _sprites.length);
  
  Animation({String name, bool loopBack:true})
  {
    _name = name;
    _isLoop = loopBack;
    _currentSpriteIndex = 0;
    _counter = 0;
  }
  
  void AddSprite(Sprite sprite, int duration)
  {
    _sprites.add(sprite);
    _durations.add(duration);
  }
  
  void update(num delta)
  {
    if (_sprites.length == 0)
      return;
    
    if (_currentSpriteIndex > _sprites.length )
      return;
    
    if (_currentSpriteIndex == _sprites.length )
    {
      _currentSpriteIndex++;
      return;
    }
    
    _counter += delta;
    if (_counter > _durations[_currentSpriteIndex])
    {
      _counter = 0;
      if (_isLoop)
      {
        _currentSpriteIndex = (_currentSpriteIndex + 1) % _sprites.length;
      }
      else
      {
        _currentSpriteIndex++;
      }
      
    }
  }
  
  Sprite GetCurrentSprite()
  {
    if (_isLoop)
    {
      return _sprites[_currentSpriteIndex];
    }
    else
    {
      return (_currentSpriteIndex < _sprites.length) ? _sprites[_currentSpriteIndex] : null;
    }
  }
}
