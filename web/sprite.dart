
part of YellowDots;

class Sprite 
{
  int src_x;
  int src_y;
  
  Sprite({int sx, int sy})
  {
    src_x = calcSrcPos(sx);
    src_y = calcSrcPos(sy);
  }
  
  int calcSrcPos(int index)
  {
    return index * 17 + 1;
  }
  
  void draw({CanvasRenderingContext2D context, int dx, int dy, int size})
  {
    ImageCache imgCache = new ImageCache();
    context.drawImage(imgCache.GetImageBuffer(),
                      src_x,
                      src_y,
                      16,
                      16,
                      dx - (size >> 1),
                      dy - (size >> 1),
                      size,
                      size);
  }
  
  String toString()
  {
    return "${src_x}:${src_y}";
  }
}
