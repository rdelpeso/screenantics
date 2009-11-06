package gui;

import java.awt.*;
import java.awt.event.*;

import resources.Palette;

public class FramePalette extends Frame {

	Button colors[] = new Button[256];
	Palette pal;
	
	public FramePalette(Palette pal)
	{
		super("Palette");
	    this.pal = pal;
		setTitle("Palette");
		setSize(522,548);
		setVisible(true);
		setLayout(null/*new GridLayout(16, 16)*/);
/*		for (int i=0; i<256; i++)
		{
			colors[i]=new Button();
			int x1=((i % 16) * 32);
			int y1=((i / 16) * 32);
			colors[i].setBounds(x1+4, y1+30, 32, 32);
			colors[i].setBackground(pal.getColor(i));
			add(colors[i]);
		}*/
		aSymWindows aSymWin = new aSymWindows();
		addWindowListener(aSymWin);
	}
	
	public void paint(Graphics g) {
		try
		{
			for (int i=0; i<256; i++)
			{
				int x1=((i % 16) * 32);
				int y1=((i / 16) * 32);
				g.setColor(Color.white);
				g.drawRect(x1+4,y1+30,34,34);
		        g.setColor(pal.getColor(i));
		        g.fillRect(x1+5, y1+31, 32, 32);
			}
		} catch (Exception ex)
		{
			ex.printStackTrace();
		}
    }
	
	public void aSymWin_windowClosing()
	{
		this.dispose();
	}
	
	class aSymWindows extends WindowAdapter {
	    public void windowClosing(WindowEvent event) {
	        aSymWin_windowClosing();
	    }
	}
}
