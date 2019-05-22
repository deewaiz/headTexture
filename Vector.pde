public static class Vec2i
{
  public int x;
  public int y;
  Vec2i(int x0, int y0) { x = x0; y = y0; }
  public static Vec2i plus (Vec2i a, Vec2i b) { return new Vec2i(a.x + b.x, a.y + b.y); }
  public static Vec2i minus(Vec2i a, Vec2i b) { return new Vec2i(a.x - b.x, a.y - b.y); }
  public static Vec2i mul  (Vec2i a, int b)   { return new Vec2i(a.x * b, a.y * b); }
  public static Vec2i mul  (Vec2i a, float b) { return new Vec2i(Math.round(a.x * b), Math.round(a.y * b)); }
}

public static class Vec2f
{
  public float x;
  public float y;
  Vec2f(float x0, float y0) { x = x0; y = y0; }
  public static Vec2f plus (Vec2f a, Vec2f b) { return new Vec2f(a.x + b.x, a.y + b.y); }
  public static Vec2f minus(Vec2f a, Vec2f b) { return new Vec2f(a.x - b.x, a.y - b.y); }
  public static Vec2f mul  (Vec2f a, float b) { return new Vec2f(a.x * b, a.y * b); }
  public static Vec2f mul  (Vec2f a, int b)   { return new Vec2f((float)(a.x * b), (float)(a.y * b)); }
}

public static class Vec3i
{
  public int x;
  public int y;
  public int z;
  Vec3i(int x0, int y0, int z0) { x = x0; y = y0; z = z0; }
  public static Vec3i plus (Vec3i a, Vec3i b) { return new Vec3i(           a.x + b.x,           a.y + b.y,           a.z + b.z); }
  public static Vec3i minus(Vec3i a, Vec3i b) { return new Vec3i(           a.x - b.x,           a.y - b.y,           a.z - b.z); }
  public static Vec3i minus(int a, Vec3i b)   { return new Vec3i(           a - b.x,             a - b.y,             a - b.z); }
  public static Vec3i minus(Vec3i a, int b)   { return new Vec3i(           a.x - b,             a.y - b,             a.z - b); }
  public static Vec3i mul  (Vec3i a, int b)   { return new Vec3i(           a.x * b,             a.y * b,             a.z * b); }
  public static Vec3i mul  (Vec3i a, float b) { return new Vec3i(Math.round(a.x * b), Math.round(a.y * b), Math.round(a.z * b)); }
  public static Vec3i divis(Vec3i a, int b)   { return new Vec3i(Math.round(a.x / b), Math.round(a.y / b), Math.round(a.z / b)); }
  public static Vec3i divis(Vec3i a, float b) { return new Vec3i(Math.round(a.x / b), Math.round(a.y / b), Math.round(a.z / b)); }
  public static float scalar      (Vec3i a, Vec3i b) { return a.x * b.x + a.y * b.y + a.z * b.z; }
  public static Vec3i crossProduct(Vec3i a, Vec3i b) { return new Vec3i(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x); }
  public Vec3f toFloat() { return new Vec3f((float)x, (float)y, (float)z); }
}

public static class Vec3f
{
  public float x;
  public float y;
  public float z;
  Vec3f(float x0, float y0, float z0) { x = x0; y = y0; z = z0; }
  public static Vec3f plus        (Vec3f a, Vec3f b) { return new Vec3f(a.x + b.x, a.y + b.y, a.z + b.z); }
  public static Vec3f minus       (Vec3f a, Vec3f b) { return new Vec3f(a.x - b.x, a.y - b.y, a.z - b.z); }
  public static Vec3f mul         (Vec3f a, float b) { return new Vec3f(a.x * b, a.y * b, a.z * b); }
  public static Vec3f mul         (Vec3f a, int b)   { return new Vec3f((float)(a.x * b), (float)(a.y * b), (float)(a.z * b)); }
  public static float scalar      (Vec3f a, Vec3f b) { return a.x * b.x + a.y * b.y + a.z * b.z; }
  public static Vec3f crossProduct(Vec3f a, Vec3f b) { return new Vec3f(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x); }
  public Vec3f normalize() { return new Vec3f(x / (float)Math.sqrt(x*x + y*y + z*z), y / (float)Math.sqrt(x*x + y*y + z*z), z / (float)Math.sqrt(x*x + y*y + z*z)); }
  public Vec3i toInt() { return new Vec3i((int)x, (int)y, (int)z); }
}

public class Vec3iCoord
{
  public int x;
  public int y;
  public int z;
  Vec3iCoord(int x0, int y0, int z0) { x = x0; y = y0; z = z0; }
}

public class Vec3iFace
{
  public int face1;
  public int face2;
  public int face3;
  Vec3iFace(int a0, int b0, int c0) { face1 = a0; face2 = b0; face3 = c0; }
}


/*

public class Vec2i
{
  public int x;
  public int y;
  
  Vec2i(int x0, int y0)
  {
    x = x0;
    y = y0;
  }
}

public class Vec2f
{
  public float x;
  public float y;
  
  Vec2f(float x0, float y0)
  {
    x = x0;
    y = y0;
  } 
}

public static class Vec3i
{
  
  public int x;
  public int y;
  public int z;
  
  Vec3i(int x0, int y0, int z0)
  {
    x = x0;
    y = y0;
    z = z0;
  }
  
  public static Vec3i minus(Vec3f a, Vec3f b)
  {
    return new Vec3i((int)(a.x - b.x), (int)(a.y - b.y), (int)(a.z - b.z));
  }
}

public class Vec3iCoord
{
  
  public int x;
  public int y;
  public int z;
  
  Vec3iCoord(int x0, int y0, int z0)
  {
    x = x0;
    y = y0;
    z = z0;
  }
}

public class Vec3iFace
{
  public int face1;
  public int face2;
  public int face3;
  
  Vec3iFace(int a0, int b0, int c0)
  {
    face1 = a0;
    face2 = b0;
    face3 = c0;
  }
}

public static class Vec3f
{
  public float x;
  public float y;
  public float z;
  
  Vec3f(float x0, float y0, float z0)
  {
    x = x0;
    y = y0;
    z = z0;
  }
  
  public static Vec3f crossProduct(Vec3f a, Vec3f b)                 // Умножение на вектор
  {
    return new Vec3f(a.y * b.z - a.z * b.y,
                     a.z * b.x - a.x * b.z, 
                     a.x * b.y - a.y * b.x);
  }
  
  public static Vec3f mul(Vec3f a, float b)                 // Умножение на вектор
  {
    return new Vec3f(a.x * b, a.y * b, a.z * b);
  }
  
  public Vec3f normalize()                                           // Нормализация
  {
    return new Vec3f(x / (float)Math.sqrt(x*x + y*y + z*z), 
                     y / (float)Math.sqrt(x*x + y*y + z*z), 
                     z / (float)Math.sqrt(x*x + y*y + z*z));
  }
  
  public static float scalar(Vec3f a, Vec3f b)
  {
    return a.x * b.x + a.y * b.y + a.z * b.z;
  }
  
  public static Vec3f minus(Vec3f a, Vec3f b)
  {
    return new Vec3f(a.x - b.x, a.y - b.y, a.z - b.z);
  }
  
  public static Vec3f minus(Vec3i a, Vec3i b)
  {
    return new Vec3f((float)(a.x - b.x), (float)(a.y - b.y), (float)(a.z - b.z));
  }
}


*/
