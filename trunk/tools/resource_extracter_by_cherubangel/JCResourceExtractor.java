package jcextractjava;

public class JCResourceExtractor {

    /**
     * @param args the command line arguments
     */

    public static void main(String[] args) {

        java.io.RandomAccessFile resourcefile;

        try {
            resourcefile = new java.io.RandomAccessFile("RESOURCE.001", "r");

            char currentChar;
            java.lang.String thisFileName = "";
            long lastResOffset = 0;
            while ((currentChar = (char)resourcefile.read()) != -1){
                lastResOffset = resourcefile.getFilePointer() - 1;
                if (currentChar != 0){
                    thisFileName += currentChar;
                } else {
                    findLastDoubleNull(resourcefile);
                    resourcefile.seek(resourcefile.getFilePointer() - 2);
                    
                    int[] byteresourceLength = new int[2];
                    byteresourceLength[0] = resourcefile.readUnsignedByte();
                    byteresourceLength[1] = resourcefile.readUnsignedByte();
                    
                    resourcefile.seek(resourcefile.getFilePointer() + 2);

                    byteresourceLength = jcTools.reverseBytes(byteresourceLength);
                    int resourceLength = jcTools.byteArrayToInt(byteresourceLength);
                    
                    java.io.RandomAccessFile outfile = new java.io.RandomAccessFile("output/" + thisFileName, "rw");
                    for (int a = 0;a < resourceLength;a++){
                        outfile.writeByte(resourcefile.readUnsignedByte());
                    }
                    outfile.close();

                    
                    System.out.println("Copied " + resourceLength + " bytes to " + thisFileName + " resource at " + lastResOffset);
                    thisFileName = "";
                }
            }

            resourcefile.close();
        } catch (java.io.FileNotFoundException e){
            System.out.println("RESOURCE.001 not found!");
            System.exit(1);
        } catch (java.io.IOException e) {
            System.out.println("Error reading from RESOURCE.001");
            System.exit(1);
        }
    }

    /* Finds the last 2 null bytes in the given file in the next 10 bytes after the pointer */
    public static void findLastDoubleNull(java.io.RandomAccessFile seekfile) throws java.io.IOException {
        try {
            int[] dNull = new int[2];
            seekfile.seek(seekfile.getFilePointer() + 8);            
            dNull[0] = seekfile.readUnsignedByte();
            dNull[1] = seekfile.readUnsignedByte();
            while (jcTools.sum(dNull) != 0){
                seekfile.seek(seekfile.getFilePointer() - 3);
                dNull[0] = seekfile.readUnsignedByte();
                dNull[1] = seekfile.readUnsignedByte();
            }
            seekfile.seek(seekfile.getFilePointer() - 2);
        } catch (java.io.IOException e){
            throw(e); // Handling in main function.
        }

    }

}
