package resources;
import java.awt.Color;

public class PaletteColor {
  int red;
  int green;
  int blue;
  PaletteColor(int red, int green, int blue)
  {
    this.red = red;
    this.green = green;
    this.blue = blue;
  }
  
  public Color getColor()
  {
    return new Color(red, green, blue);
  }
}
