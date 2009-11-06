
public class ResourceInfo {

	private String name;
	private int unknown;
	private int offset;
	private int size;
  private String resourcefile;
	
	public ResourceInfo(String resourcefile, int unknown, int offset, String name, int size)
	{
	  this.resourcefile = resourcefile;
	  this.unknown = unknown;
	  this.offset = offset;
	  this.name = name;
	  this.size = size;
	}
	
	public String getName() { return name; }
	public int getOffset() { return offset; }
	public int getUnknown() { return unknown; }
	public int getSize() { return size; }
	public String getResourceFile() { return resourcefile; }
}
