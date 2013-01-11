part of YellowDots;

class ImageCache 
{
  static final ImageCache _imgCache = new ImageCache._internal();
  static ImageElement _img = null;
  static const String _imgPath = "SpriteSheet.png";
  
  factory ImageCache()
  {
    if (_img == null)
    {
      _img = new ImageElement();
      _img.src = _imgPath;
      _img.on.load.add((event) {
        print("load image done.");
      });
    }
    return _imgCache;
  }
  
  ImageCache._internal();
  
  ImageElement GetImageBuffer() => _img;
}
