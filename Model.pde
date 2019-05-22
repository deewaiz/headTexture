import java.util.*;
BufferedReader reader;

public class Model
{
  private String line;
/////////////////////////////////////////////////////////////////////////////////////////// Координаты вершин - v
  private List<Vec3i> screenV = new ArrayList<Vec3i>();                                  // 
  private List<Vec3f> worldV = new ArrayList<Vec3f>();                                   //
///////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////// Текстурные координаты - vt
//  private List<Vec2i> screenVT = new ArrayList<Vec2i>();                                 //
  private List<Vec2f> worldVT = new ArrayList<Vec2f>();                                  //
///////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////// Грани - f
  private List<Vec3iFace> Fv = new ArrayList<Vec3iFace>();                               //
  private List<Vec3iFace> Ft = new ArrayList<Vec3iFace>();                               //
///////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////// Получить индекс грани из f  
  public Vec3iFace getFaceV(int n) { return Fv.get(n); }                                 // 
  public int getFaceCount() { return Fv.size(); }                                        //
///////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////// Получить индекс текстур из f
  public Vec3iFace getFaceT(int n) { return Ft.get(n); }                                 //
  public int getFaceTCount() { return Ft.size(); }                                       //
///////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////// Получить координаты вершин(v) по индексу
  public Vec3i getScreenV(int n) { return screenV.get(n); }                              //
  public Vec3f getWorldV(int n) { return worldV.get(n); }                                // f v/0/0 v/0/0 v/0/0
  public int getCountV() { return screenV.size(); }                                      //
///////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////// Получить координаты текстур(vt) по индексу
//  public Vec2i getScreenVT(int n) { return screenVT.get(n); }                            //
  public Vec2f getWorldVT(int n) { return worldVT.get(n); }                              // f 0/vt/0 0/vt/0 0/vt/0
  public int getCountVT() { return worldVT.size(); }                                     //
///////////////////////////////////////////////////////////////////////////////////////////

  private int v = 0;  
  private int vt = 0;
  private int f = 0;
  
  Model(String fileName)
  {
    reader = createReader(fileName);
    line = "";
    
    while(line != null)
    {
      try { line = reader.readLine(); }
      catch (IOException e) { e.printStackTrace(); line = null; }
      if (line == null) { noLoop(); }
      else
      {
        // Parsing vertexes
        if (match(line, "v ") != null)
        {
          String vertex[] = line.split(" ");
          worldV.add(new Vec3f(Float.parseFloat(vertex[1]), 
                               Float.parseFloat(vertex[2]), 
                               Float.parseFloat(vertex[3])));
          screenV.add(new Vec3i(Math.round((Float.parseFloat(vertex[1]) + 1) * width / 2), 
                                Math.round((Float.parseFloat(vertex[2]) + 1) * height / 2), 
                                Math.round((Float.parseFloat(vertex[3]) + 1) * 255 / 2)));
          
          //println("Xw is " + Vworld.get(v).x +  ", Yw is " + Vworld.get(v).y +  ", Zw is " + Vworld.get(v).z);
          //println("Xs is " + Vscreen.get(v).x + ", Ys is " + Vscreen.get(v).y + ", Zs is " + Vscreen.get(v).z);
          v++;
        }
        // Parsing texture vertexes
        if (match(line, "vt  ") != null)
        {
          String vertex[] = line.split(" ");
          worldVT.add(new Vec2f(Float.parseFloat(vertex[2]), 
                                Float.parseFloat(vertex[3])));
          //screenVT.add(new Vec2i(Math.round((Float.parseFloat(vertex[2]) + 1) * width / 2), 
          //                       Math.round((Float.parseFloat(vertex[3]) + 1) * height / 2)));
          //println("Xtw is " + Vtworld.get(vt).x +  ", Ytw is " + Vtworld.get(vt).y);
          //println("Xts is " + Vtscreen.get(vt).x + ", Yts is " + Vtscreen.get(vt).y);
          vt++;
        }
        // Parsing faces
        if (match(line, "f ") != null)
        {
          String faces[] = line.split(" ");

          Fv.add(new Vec3iFace(Integer.parseInt(faces[1].split("/")[0]),
                               Integer.parseInt(faces[2].split("/")[0]),
                               Integer.parseInt(faces[3].split("/")[0])));
          Ft.add(new Vec3iFace(Integer.parseInt(faces[1].split("/")[1]),
                               Integer.parseInt(faces[2].split("/")[1]),
                               Integer.parseInt(faces[3].split("/")[1])));
          
          //println("Fv1 is " + Fv.get(f).face1 + ", Fv2 is " + Fv.get(f).face2 + ", Fv3 is " + Fv.get(f).face3);
          //println("Ft1 is " + Ft.get(f).face1 + ", Ft2 is " + Ft.get(f).face2 + ", Ft3 is " + Ft.get(f).face3);
          f++;
        }
      }
    }
    println(v + " vertices." + "Vtworld size is " + worldV.size() + ". Vtscreen size is " + screenV.size() + ".");
    println(vt + " texture vertices. " + "Vtworld size is " + worldVT.size() + ".");
    println(f + " faces. " + "Fv size is " + Ft.size() + ". Ft size is " + Fv.size() + ".");
  }
}
