class RasterTrigon
{ 
  void plotTriangle(Vec3i p0, Vec3i p1, Vec3i p2, Vec2i t0, Vec2i t1, Vec2i t2, Texture texture, float intensity, int[] zbuffer)
  {
    // Отсечение дегенеративных треугольников
    if (p0.y == p1.y && p0.y == p2.y) return;
    
    // Сортировка вершин треугольника по оси Y
    if (p0.y>p1.y) { p1 = swap(p0, p0 = p1); t1 = swap(t0, t0 = t1); }
    if (p0.y>p2.y) { p2 = swap(p0, p0 = p2); t2 = swap(t0, t0 = t2); }
    if (p1.y>p2.y) { p2 = swap(p1, p1 = p2); t2 = swap(t1, t1 = t2); }
    
    // Закраска треугольника
    int trigon_height = p2.y - p0.y;
    for (int i = 0; i < trigon_height; i++)
    {
      // Разбиение треугольника на две части
      boolean second_half = i > p1.y - p0.y || p1.y == p0.y;
      
      // Вычисление высоты половинки треугольника
      int segment_height = second_half ? p2.y - p1.y
                                       : p1.y - p0.y;
      // Вычисление множителей для интерполяционного двучлена
      float aplha = (float)i / trigon_height;
      float beta  = (float)(i - (second_half ? p1.y - p0.y : 0)) / segment_height;
      
      // Интерполирование координат для левой и правой границ треугольника
      Vec3i A =               Vec3i.plus(Vec3i.mul(Vec3i.minus(p2, p0), aplha), p0); // p0 + (p2 - p0) * left_side
      Vec3i B = second_half ? Vec3i.plus(Vec3i.mul(Vec3i.minus(p2, p1), beta), p1)   // p1 + (p2 - p1) * right_side
                            : Vec3i.plus(Vec3i.mul(Vec3i.minus(p1, p0), beta), p0);  // p0 + (p1 - p0) * right_side
      // Для текстуры                      
      Vec2i tA =               Vec2i.plus(Vec2i.mul(Vec2i.minus(t2, t0), aplha), t0);
      Vec2i tB = second_half ? Vec2i.plus(Vec2i.mul(Vec2i.minus(t2, t1), beta), t1)
                             : Vec2i.plus(Vec2i.mul(Vec2i.minus(t1, t0), beta), t0);

      if (A.x > B.x) {B = swap(A, A = B); tB = swap(tA, tA = tB);}
      
      //  Заполнение горизонтальной линией
      for (int j = A.x; j < B.x; j++) 
      { 
        // Вычисление множителя для интерполяционного двучлена
        float phi = B.x == A.x ? 1. 
                               : (float)(j - A.x) / (float)(B.x - A.x);
                               
        // Интерполирование Z координаты                       
        Vec3i P = Vec3i.plus(Vec3i.mul(Vec3i.minus(B, A), phi), A);     // A + (B - A) * phi
        
        // Для текстуры
        Vec2i tP = Vec2i.plus(Vec2i.mul(Vec2i.minus(tB, tA), phi), tA);

        int idx = P.x + P.y * width;
        if (zbuffer[idx] < P.z)
        {
          zbuffer[idx] = P.z;
          
          // int[]
          //int r = texture.getRed  (tP.x + tP.y * texture.getWidth());
          //int g = texture.getGreen(tP.x + tP.y * texture.getWidth());
          //int b = texture.getBlue (tP.x + tP.y * texture.getWidth());
          
          // int[][]
          int r = texture.getRed  (tP.x, tP.y);
          int g = texture.getGreen(tP.x, tP.y);
          int b = texture.getBlue (tP.x, tP.y);
          
          set(P.x, P.y, color(r * intensity, g * intensity, b * intensity));
        }
      }
    }
  }

    
  private Vec2i swap(Vec2i a, Vec2i b) { return a; } // usage: y = swap(x, x=y);
  private Vec3i swap(Vec3i a, Vec3i b) { return a; } // usage: y = swap(x, x=y);

}
    
