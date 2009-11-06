import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import resources.*;

public class ResourceMap {

  ResourceTable resources = new ResourceTable();
  byte[] unknown = new byte[6];
  String path;
  
  // Read 0 terminated string from map file
  private String readResourceFileName(DataInputStream dis) throws IOException
  {
    String ret = "";
    int b = dis.readUnsignedByte();
    while (b!=0)
    {
    ret+=(char)(b & 0xFF);
      b = dis.readUnsignedByte();
    }
    return ret;
  }
  
  // Write integer as 8 hexadecimal chars
  private String hexDWord(int h)
  {
    String ret = Integer.toHexString(h);
    while (ret.length()<8)
    {
      ret="0"+ret;
    }
    return ret;
  }
  
  // Since file is stored as Little-Endian but Java reads as Big-Endian
  // Special functions to read 2 and 4 byte numbers are necessary
  private int readWord(DataInputStream dis) throws IOException // Reads two bytes
  {
  int b1 = dis.readUnsignedByte();
  int b2 = dis.readUnsignedByte();
    int i = (b2 * 256) + b1;
    return i;
  }
   
  private int readDWord(DataInputStream dis) throws IOException // Reads 4 bytes
  {   
    int b1 = dis.readUnsignedByte();
    int b2 = dis.readUnsignedByte();
    int b3 = dis.readUnsignedByte();
    int b4 = dis.readUnsignedByte();
    int i = ((b4 * 256 + b3) * 256 + b2) * 256 + b1;
    return i;
  }
  
  public void load(String resourcemap)
  {
    try
    {
      int tableno = 0;
    File file = new File(resourcemap);
    // Construct full path to file
    String sFullPath = file.getCanonicalPath();
    String sPath = sFullPath.substring(0,sFullPath.lastIndexOf("\\")+1);
    path = sPath;
    FileInputStream fismap = new FileInputStream(file);
    DataInputStream dismap = new DataInputStream(fismap);

      // First 6 bytes are unknown
      for (int i=0; i<6; i++)
      {
       unknown[i]= dismap.readByte();
      }
      String sResourceFileName = readResourceFileName(dismap);
      String sResourceFile = sPath + sResourceFileName;
      while (sResourceFile!=null)
      {
    // Next is the name of the resource file to read
      System.out.println("Resource file: "+sResourceFile);
      
      File fileres = new File(sResourceFile);
      if (fileres.exists())
      {
        DataReader resreader = new DataReader(fileres);
        // Word containing the amount of resources in the resource file
        int rescount = readWord(dismap);
        System.out.println("Total resources: "+rescount);
        System.out.println("Resource\tUnknown  \tOffset\tFirst16");
        // Read individual resource
        String resname="";
        int oldoffset=0;
        int U=0;
//        String first16 = "";
        for (int iRes=0; iRes<rescount; iRes++)
        {
          // 4 unknown bytes
          U = readDWord(dismap);
          // 4 byte offset of resource in resource file
          int offset = readDWord(dismap);
          if (iRes>0)
          {
          ResourceInfo entry =new ResourceInfo(sResourceFileName, U, oldoffset+resname.length()+1, resname, offset-oldoffset-resname.length()-1);
          resources.add(entry);
//          first16=extractResource(sPath+resname,oldoffset+resname.length()+1,offset-oldoffset-resname.length()-1);
//            System.out.println(first16);
          }
          resname = resreader.readZeroString(offset);
          System.out.println(resname+"\t"+ hexDWord(U)+"\t"+hexDWord(offset)+"\t");
          oldoffset=offset;
        }
        ResourceInfo entry =new ResourceInfo(sResourceFileName, U, oldoffset+resname.length()+1, resname, (int) (fileres.length()-oldoffset-resname.length()-1));
        resources.add(entry);
//        first16=extractResource(sPath+resname,oldoffset+resname.length()+1,(int)fileres.length()-oldoffset-resname.length()-1); 
//              System.out.println(first16);
        }
        
        tableno++;
        sResourceFile = sPath + readResourceFileName(dismap);
      }
    } catch (Exception ex)
    {
      System.out.println(ex.toString());
    }
  }
  
  public Resource read(String name)
  {
    ResourceInfo resinfo = resources.getResourceInfo(name);
    
    if (name.toUpperCase().endsWith(".PAL"))
    {
      return (Resource)readPalette(resinfo);
    }
    return null;
  }
  
  public Palette readPalette(ResourceInfo resinfo)
  {
    File resfile = new File(path+resinfo.getResourceFile());
    DataReader drpal = new DataReader(resfile);
    Palette pal = null;
    try
    {
      drpal.setOffset(resinfo.getOffset());
      int datasize = drpal.readDWord();
      int b1=drpal.readByte(); // P
      int b2=drpal.readByte(); // A
      int b3=drpal.readByte(); // L
      int b4=drpal.readByte(); // :
      int u1=drpal.readWord();
      int u2=drpal.readWord();
      int b5=drpal.readByte(); // P
      int b6=drpal.readByte(); // A
      int b7=drpal.readByte(); // L
      int b8=drpal.readByte(); // :   
      // 772
      int colors = (datasize-16)/3;
      pal = new Palette(colors);
      for (int i=0; i<colors; i++)
      {
        int r = drpal.readByte();
        int g = drpal.readByte();
        int b = drpal.readByte();
        pal.setRGBColor(i, r*4, g*4, b*4);
      }
    } catch (Exception ex)
    {
      System.out.println(ex.toString()); 
    }
    return pal;
    
  }
  
  public void fillList(java.awt.List l)
  {
    for (int i=0; i<resources.getSize(); i++)
    {
    	l.add(resources.getName(i));
    }
  }
}
