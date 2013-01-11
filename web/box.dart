part of YellowDots;

class Box2D 
{
  int cx;
  int cy;
  int extX;
  int extY;
  
  int width()  => extX << 1;
  int height() => extY << 1;
  int left()   => cx - extX;
  int right()  => cx + extX;
  int top()    => cy - extY;
  int bottom() => cy + extY;
  
  Box2D.Rect({int l, int t, int width, int height})
  {
    extX = width >> 1;
    extY = height >> 1;
    cx = l + extX;
    cy = t + extY;
  }
  
  Box2D.AABB({int x, int y, int width, int height})
  {
    extX = width >> 1;
    extY = height >> 1;
    cx = x;
    cy = y;
  }
  
  bool isOverlaped(Box2D other)
  {
    return ((other.cx - cx).abs() <= other.extX + extX) &&
           ((other.cy - cy).abs() <= other.extY + extY);
  }
  
  String toString()
  {
    return "cx:$cx cy:$cy ext:[$extX,$extY]";
  }
}
