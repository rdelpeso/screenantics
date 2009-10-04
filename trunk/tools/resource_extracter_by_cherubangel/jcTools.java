/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package jcextractjava;

/**
 *
 * @author Jaap
 */
public class jcTools {
    public static int byteArrayToInt(int[] b) {
        /*
        int value = 0;
        for (int i = 0; i < b.length; i++) {
            int shift = (b.length - 1 - i) * 8;
            value += (b[i] & 0x000000FF) << shift;
        }
        return value;
        */
        int value = 0;
        for (int i = 0; i < b.length; i++) {
            int shift = (b.length - 1 - i) * 8;
            value += (b[i] & 0x000000FF) << shift;
        }
        return value;
    }


    public final static int[] reverseBytes(int[] input){
        int[] output = new int[input.length];
        for (int a = 0;a < input.length; a++){
            output[output.length - a - 1] = input[a];
        }
        return output;
    }

    public final static int sum(int[] summable){
        int retval = 0;
        for (int thisval: summable) retval += thisval;
        return retval;
    }
}
