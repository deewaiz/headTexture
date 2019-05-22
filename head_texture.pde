import java.io.*;

Model model;
Texture texture;
//int[] texture;

void setup()
{
  size(850, 850);
  background(color(0, 0, 0));
  model = new Model("african_head.obj");
  //texture = loadTexture("/Users/deewaiz/GraphicsLearning/Processing/11_head_texture/head_texture/african_head_diffuse.tga");
  texture = new Texture("/Users/deewaiz/GraphicsLearning/Processing/11_head_texture/head_texture/african_head_diffuse.tga");
}

void draw()
{
  drawModel(model, texture);
  println("enddraw");
}

void drawModel(Model model, Texture texture)
{
  RasterTrigon trigon = new RasterTrigon();;

  // Инициализация и заполнение буфера глубины
  int zbuffer[] = new int[width * height];
  for (int i = 0; i < width * height; i++) { zbuffer[i] = java.lang.Integer.MIN_VALUE; }
  
  // Построение модели
  for (int i = 0; i < model.getFaceCount(); i++) 
  {
    // Инициализация вершин треугольника
    Vec3i p0 = new Vec3i(width - model.getScreenV(model.getFaceV(i).face1 - 1).x, height - model.getScreenV(model.getFaceV(i).face1 - 1).y, model.getScreenV(model.getFaceV(i).face1 - 1).z);
    Vec3i p1 = new Vec3i(width - model.getScreenV(model.getFaceV(i).face2 - 1).x, height - model.getScreenV(model.getFaceV(i).face2 - 1).y, model.getScreenV(model.getFaceV(i).face2 - 1).z);
    Vec3i p2 = new Vec3i(width - model.getScreenV(model.getFaceV(i).face3 - 1).x, height - model.getScreenV(model.getFaceV(i).face3 - 1).y, model.getScreenV(model.getFaceV(i).face3 - 1).z);
    
    // Просчет плоского освещения (intensity)
    Vec3f light_dir = new Vec3f(0, 0, 1);
    Vec3f A = Vec3f.minus(model.getWorldV(model.getFaceV(i).face2 - 1), model.getWorldV(model.getFaceV(i).face1 - 1));
    Vec3f B = Vec3f.minus(model.getWorldV(model.getFaceV(i).face3 - 1), model.getWorldV(model.getFaceV(i).face1 - 1));                    
    Vec3f C = Vec3f.crossProduct(A, B);
    Vec3f N = C.normalize();
    float intensity  = Vec3f.scalar(N, light_dir);
    
    // Условие быстрого отсечения невидимых треугольников
    if (intensity > 0)
    { //<>//
      // Инициализация текстурных вершин
      Vec2i t0 = new Vec2i(texture.getWidth() - (Math.round((model.getWorldVT(model.getFaceT(i).face1 - 1).x) * texture.getWidth())),
                          (texture.getHeight() - Math.round((model.getWorldVT(model.getFaceT(i).face1 - 1).y) * texture.getHeight())));
      
      Vec2i t1 = new Vec2i(texture.getWidth() - (Math.round((model.getWorldVT(model.getFaceT(i).face2 - 1).x) * texture.getWidth())),
                          (texture.getHeight() - Math.round((model.getWorldVT(model.getFaceT(i).face2 - 1).y) * texture.getHeight())));
      
      Vec2i t2 = new Vec2i(texture.getWidth() - (Math.round((model.getWorldVT(model.getFaceT(i).face3 - 1).x) * texture.getWidth())),
                          (texture.getHeight() - Math.round((model.getWorldVT(model.getFaceT(i).face3 - 1).y) * texture.getHeight())));
      
      // Вызов функции растеризации треугольника
      trigon.plotTriangle(p0, p1, p2, t0, t1, t2, texture, intensity, zbuffer);
    }

  }
}
