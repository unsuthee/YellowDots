part of YellowDots;

abstract class GameObject 
{
  Environment _env;
  Box2D _box;
  
  GameObject(Environment env, Box2D box)
  {
    _env = env;
    _box = box;
  }
  
  Box2D box() => _box;
  Environment env() => _env;
  
  void update(num delta);
  
  void draw(CanvasRenderingContext2D ctx);  
  
  void onCollide(GameObject other);
  
  bool isOverlapped(GameObject other)
  {
    return (other.box().isOverlaped(_box));
  }
  
}
