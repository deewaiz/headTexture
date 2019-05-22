import java.io.*;

public class Texture {
  
  private int[] texture;
  private int textureWidth;
  private int textureHeight;

  public int getRed  (int idx) { return (texture[idx] >> 16) & 0xFF; }
  public int getGreen(int idx) { return (texture[idx] >> 8 ) & 0xFF; }
  public int getBlue (int idx) { return (texture[idx]      ) & 0xFF; }
  
  public int getRed  (int x, int y) { return (texture[x + y * textureWidth] >> 16) & 0xFF; }
  public int getGreen(int x, int y) { return (texture[x + y * textureWidth] >> 8 ) & 0xFF; }
  public int getBlue (int x, int y) { return (texture[x + y * textureWidth]      ) & 0xFF; }
  
  public int getWidth()  { return textureWidth; }
  public int getHeight() { return textureHeight; }

  
  Texture(String path)
  {
    byte [] buffer;
    try 
    {
      FileInputStream fis = new FileInputStream(new File(path));
      buffer = new byte[fis.available()];
      fis.read(buffer);
      texture = TGAReader.read(buffer, TGAReader.ARGB);
      fis.close();
      textureWidth = TGAReader.getWidth(buffer);
      textureHeight = TGAReader.getHeight(buffer);
      println("Texture loaded.");
    }
    catch(IOException ex)
    {
      println("Texture was not loaded.");
      texture = null;
      return;
    }
  }
}
