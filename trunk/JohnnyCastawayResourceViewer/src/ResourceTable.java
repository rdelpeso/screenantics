import java.util.ArrayList;
import java.util.HashMap;

public class ResourceTable {

  HashMap<String, ResourceInfo> resmap = new HashMap<String, ResourceInfo>();
  ArrayList<String> strings = new ArrayList<String>();
  int size = 0;
  
  public ResourceTable()
  {
  }
  
  public void add(ResourceInfo resinfo)
  {
    resmap.put(resinfo.getName(), resinfo);
    strings.add(resinfo.getName());
    size++;
  }
  
  public ResourceInfo getResourceInfo(String name)
  {
    return resmap.get(name);
  }
  
  public String getName(int index)
  {
    return strings.get(index);
  }
  
  public int getSize()
  {
	return size;  
  }
}
