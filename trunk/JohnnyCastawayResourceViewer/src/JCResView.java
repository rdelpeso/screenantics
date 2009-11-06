import java.awt.*;
import java.applet.*;
import resources.*;
import gui.*;

public class JCResView extends Applet {
  private Button btnview = new Button("View");
  private Label lblresources = new Label("Resources:"); 
  private List lstres = new List();
  ResourceMap map;
  
  public void init() {
    setLayout(null);
    setSize(250,450);
    setBackground(Color.lightGray);
    lblresources.setBounds(10,10, 90,22);
    lstres.setBounds(10, 35, 200, 400);
    btnview.setBounds(100,10, 50, 22);
	SymMouse aSymMouse = new SymMouse();
	btnview.addMouseListener(aSymMouse);
    add(lblresources);
    add(lstres);
    add(btnview);
    map = new ResourceMap();
    map.load("C:\\SIERRA\\SCRANTIC\\RESOURCE.MAP");
    map.fillList(lstres);
  }

	class SymMouse extends java.awt.event.MouseAdapter
	{
		public void mouseClicked(java.awt.event.MouseEvent event)
		{
			Object object = event.getSource();
			if (object == btnview)
				bExecute_MouseClicked(event);
		}
	}

	void bExecute_MouseClicked(java.awt.event.MouseEvent event)
	{
		String resname = lstres.getSelectedItem();
		if (resname.endsWith(".PAL"))
		{
			Palette pal = (Palette)map.read(resname);
			FramePalette fp = new FramePalette(pal);
		}
	}
   
  public static void main(String[] args) {
//    run(new JohnnyCastawayResourceViewer(), 400, 300);
  }
/*   
  public static void run(JApplet applet, int width, int height) {
    JFrame frame = new JFrame();
    frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    frame.getContentPane().add(applet);
    frame.setSize(width, height);
    applet.init();
    applet.start();
    frame.setVisible(true);
  }
  */
  /*
  Button beepButton = new Button("Beep");  
add(beepButton); 
ResourceList reslist = new ResourceList();

     map.load("C:\\sierra\\scrantic\\resource.map");
	   Palette pal = (Palette)map.read("JOHNCAST.PAL"); // Offset 1117171
	   */
	   // INTRO.SCR // Offset 1098275
//	   BACKGRND.BMP // 1151597
	   // MRAFT.BMP // 929502
	   // JOHNWALK.BMP // 1117972
	   // OCEAN01.SCR // 1138593
	   // VISITOR.ADS // 577871
	   // GJVIS3.TTM // 639212
	   // VISITOR.ADS // 577932 (02 GJLILIPU.TTM)
	   // VISITOR.ADS // 577947 (03 GJVIS6.TTM)
//	   FISHING.ADS // 
//	   MJFISH.TTM  
}