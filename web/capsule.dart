part of YellowDots;

class Capsule
{
  int _animationFrameRate = 8;
  int _counter = 0;
  int _tx;
  int _ty;
  
  int get tilex => _tx;
  int get tiley => _ty;
  
  Capsule({int tx, int ty})
  {
    _tx = tx;
    _ty = ty;
  }
  
  void update(num delta)
  {
    _counter++;
    if (_counter > _animationFrameRate * 2)
    {
      _counter = 0;
    }
  }
  
  void draw(CanvasRenderingContext2D ctx, int size)
  {
    if (_counter < _animationFrameRate)
    {
      ImageCache imgCache = new ImageCache();
      int sx = 2 * 17 + 1;
      int sy = 15 * 17 + 1;
      int px = _tx * DEF.SIZE_BLOCK - DEF.SIZE_HALF_BLOCK;
      int py = _ty * DEF.SIZE_BLOCK - DEF.SIZE_HALF_BLOCK;
      ctx.drawImage(imgCache.GetImageBuffer(),
          sx, sy, 16, 16,
          px,
          py,
          size,
          size);
    }
  }
  
  bool isOverlapped(Agent pacman)
  {
    return true;
  }
}
