import java.io.FileOutputStream;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.io.File;

public class DataReader {

    private RandomAccessFile rafres; // Used to read from the resource file

	public DataReader(File resourcefile)
	{
	  try
	  {
      rafres = new RandomAccessFile(resourcefile, "r");
	  } catch (Exception ex)
	  {
	    System.out.println(ex.toString());
	  }
	}

	public void setOffset(int offset) throws IOException
	{
	  rafres.seek(offset);
	}
	
	// Read 0 terminated string at offset from resource file
	public String readZeroString(long offset)
	{
    String ret = "";
	  try
	  {
      rafres.seek(offset);
      int b = rafres.readUnsignedByte();
      while (b!=0)
      {
        ret+=(char)(b & 0xFF);
        b = rafres.readUnsignedByte();
      }
    } catch (Exception ex) { }
	  return ret;
	}
	
	public int readByte()throws IOException
	{
	  return rafres.readUnsignedByte();
	}
	
  public int readWord() throws IOException // Reads two bytes
  {
  int b1 = rafres.readUnsignedByte();
  int b2 = rafres.readUnsignedByte();
    int i = (b2 * 256) + b1;
    return i;
  }
   
  public int readDWord() throws IOException // Reads 4 bytes
  {   
    int b1 = rafres.readUnsignedByte();
    int b2 = rafres.readUnsignedByte();
    int b3 = rafres.readUnsignedByte();
    int b4 = rafres.readUnsignedByte();
    int i = ((b4 * 256 + b3) * 256 + b2) * 256 + b1;
    return i;
  }
	
	public String extractResource(String filepath, int offset, int size) throws IOException
	{
      byte b[] = new byte[size];
      rafres.seek(offset);
	  rafres.read(b);
	  String res = "";
	  String str = "";
	  for (int i=0; i<16; i++)
	  {
	    int val = b[i] & 0xFF;
	    if (val>=32 && val<=126)
	      str+=(char)(b[i] & 0xFF);
	    else
	    	str+=".";
	    String shex = Integer.toHexString(val);
	    if (shex.length()==1) shex = "0"+shex;
	    res += shex;
	  }
      FileOutputStream fos = new FileOutputStream(filepath);
      fos.write(b);
      fos.close();
      return "0x" + res+"\t"+str;
	}
	
}
