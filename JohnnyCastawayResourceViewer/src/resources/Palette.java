package resources;
import java.awt.Color;

public class Palette extends Resource {

  private int size;
  private PaletteColor col[] = new PaletteColor[256];

  public Palette(int size) {
    this.size = size;
  }

  public void setRGBColor(int index, int red, int green, int blue)
  {
	col[index] = new PaletteColor(red, green, blue);
  }
  
  public Color getColor(int index)
  {
    return new Color(col[index].red, col[index].green, col[index].blue);
  }
  
  public int getSize()
  {
    return size;
  }
}
