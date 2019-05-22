/**
 * TGAReader.java
 * 
 * Copyright (c) 2014 Kenji Sasaki
 * Released under the MIT license.
 * https://github.com/npedotnet/TGAReader/blob/master/LICENSE
 * 
 * English document
 * https://github.com/npedotnet/TGAReader/blob/master/README.md
 * 
 * Japanese document
 * http://3dtech.jp/wiki/index.php?TGAReader
 * 
 */

//package net.npe.tga;

import java.io.IOException;

public static class TGAReader {
  
  public static final Order ARGB = new Order(16, 8, 0, 24);
  public static final Order ABGR = new Order(0, 8, 16, 24);
  
  public static int getWidth(byte [] buffer) {
    return (buffer[12] & 0xFF) | (buffer[13] & 0xFF) << 8;
  }
  
  public static int getHeight(byte [] buffer) {
    return (buffer[14] & 0xFF) | (buffer[15] & 0xFF) << 8;
  }
  
  public static int [] read(byte [] buffer, Order order) throws IOException {
    
    // header
//    int idFieldLength = buffer[0] & 0xFF;
//    int colormapType = buffer[1] & 0xFF;
    int type = buffer[2] & 0xFF;
    int colormapOrigin = (buffer[3] & 0xFF) | (buffer[4] & 0xFF) << 8;
    int colormapLength = (buffer[5] & 0xFF) | (buffer[6] & 0xFF) << 8;
    int colormapDepth = buffer[7] & 0xFF;
//    int originX = (buffer[8] & 0xFF) | (buffer[9] & 0xFF) << 8; // unsupported
//    int originY = (buffer[10] & 0xFF) | (buffer[11] & 0xFF) << 8; // unsupported
    int wdth = getWidth(buffer);
    int hght = getHeight(buffer);
    int depth = buffer[16] & 0xFF;
    int descriptor = buffer[17] & 0xFF;
      
    int [] pxls = null;
    
    // data
    switch(type) {
    case COLORMAP: {
      int imageDataOffset = 18 + (colormapDepth / 8) * colormapLength;
      pxls = createPixelsFromColormap(wdth, hght, colormapDepth, buffer, imageDataOffset, buffer, colormapOrigin, descriptor, order);
      } break;
    case RGB:
      pxls = createPixelsFromRGB(wdth, hght, depth, buffer, 18, descriptor, order);
      break;
    case GRAYSCALE:
      pxls = createPixelsFromGrayscale(wdth, hght, depth, buffer, 18, descriptor, order);
      break;
    case COLORMAP_RLE: {
      int imageDataOffset = 18 + (colormapDepth / 8) * colormapLength;
      byte [] decodeBuffer = decodeRLE(wdth, hght, depth, buffer, imageDataOffset);
      pxls = createPixelsFromColormap(wdth, hght, colormapDepth, decodeBuffer, 0, buffer, colormapOrigin, descriptor, order);
      } break;
    case RGB_RLE: {
      byte [] decodeBuffer = decodeRLE(wdth, hght, depth, buffer, 18);
      pxls = createPixelsFromRGB(wdth, hght, depth, decodeBuffer, 0, descriptor, order);
      } break;
    case GRAYSCALE_RLE: {
      byte [] decodeBuffer = decodeRLE(wdth, hght, depth, buffer, 18);
      pxls = createPixelsFromGrayscale(wdth, hght, depth, decodeBuffer, 0, descriptor, order);
      } break;
    default:
      throw new IOException("Unsupported image type: "+type);
    }
    
    return pxls;
    
  }
  
  private static final int COLORMAP = 1;
  private static final int RGB = 2;
  private static final int GRAYSCALE = 3;
  private static final int COLORMAP_RLE = 9;
  private static final int RGB_RLE = 10;
  private static final int GRAYSCALE_RLE = 11;
  
  private static final int RIGHT_ORIGIN = 0x10;
  private static final int UPPER_ORIGIN = 0x20;
  
  private static byte [] decodeRLE(int wdth, int hght, int depth, byte [] buffer, int offset) {
    int elementCount = depth/8;
    byte [] elements = new byte[elementCount];
    int decodeBufferLength = elementCount * wdth * hght;
    byte [] decodeBuffer = new byte[decodeBufferLength];
    int decoded = 0;
    while(decoded < decodeBufferLength) {
      int packet = buffer[offset++] & 0xFF;
      if((packet & 0x80) != 0) { // RLE
        for(int i=0; i<elementCount; i++) {
          elements[i] = buffer[offset++];
        }
        int count = (packet&0x7F)+1;
        for(int i=0; i<count; i++) {
          for(int j=0; j<elementCount; j++) {
            decodeBuffer[decoded++] = elements[j];
          }
        }
      }
      else { // RAW
        int count = (packet+1) * elementCount;
        for(int i=0; i<count; i++) {
          decodeBuffer[decoded++] = buffer[offset++];
        }
      }
    }
    return decodeBuffer;
  }
  
  private static int [] createPixelsFromColormap(int wdth, int hght, int depth, byte [] bytes, int offset, byte [] palette, int colormapOrigin, int descriptor, Order order) throws IOException {
    int [] pxls  = null;
    int rs = order.redShift;
    int gs = order.greenShift;
    int bs = order.blueShift;
    int as = order.alphaShift;
    switch(depth) {
    case 24:
      pxls = new int[wdth*hght];
      if((descriptor & RIGHT_ORIGIN) != 0) {
        if((descriptor & UPPER_ORIGIN) != 0) {
          // UpperRight
          for(int i=0; i<hght; i++) {
            for(int j=0; j<wdth; j++) {
              int colormapIndex = bytes[offset+wdth*i+j] & 0xFF - colormapOrigin;
              int c = 0xFFFFFFFF;
              if(colormapIndex >= 0) {
                int index = 3*colormapIndex+18;
                int b = palette[index+0] & 0xFF;
                int g = palette[index+1] & 0xFF;
                int r = palette[index+2] & 0xFF;
                int a = 0xFF;
                c = (r<<rs) | (g<<gs) | (b<<bs) | (a<<as);
              }
              pxls[wdth*i+(wdth-j-1)] = c;
            }
          }
        }
        else {
          // LowerRight
          for(int i=0; i<hght; i++) {
            for(int j=0; j<wdth; j++) {
              int colormapIndex = bytes[offset+wdth*i+j] & 0xFF - colormapOrigin;
              int c = 0xFFFFFFFF;
              if(colormapIndex >= 0) {
                int index = 3*colormapIndex+18;
                int b = palette[index+0] & 0xFF;
                int g = palette[index+1] & 0xFF;
                int r = palette[index+2] & 0xFF;
                int a = 0xFF;
                c = (r<<rs) | (g<<gs) | (b<<bs) | (a<<as);
              }
              pxls[wdth*(hght-i-1)+(wdth-j-1)] = c;
            }
          }
        }
      }
      else {
        if((descriptor & UPPER_ORIGIN) != 0) {
          // UpperLeft
          for(int i=0; i<hght; i++) {
            for(int j=0; j<wdth; j++) {
              int colormapIndex = bytes[offset+wdth*i+j] & 0xFF - colormapOrigin;
              int c = 0xFFFFFFFF;
              if(colormapIndex >= 0) {
                int index = 3*colormapIndex+18;
                int b = palette[index+0] & 0xFF;
                int g = palette[index+1] & 0xFF;
                int r = palette[index+2] & 0xFF;
                int a = 0xFF;
                c = (r<<rs) | (g<<gs) | (b<<bs) | (a<<as);
              }
              pxls[wdth*i+j] = c;
            }
          }
        }
        else {
          // LowerLeft
          for(int i=0; i<hght; i++) {
            for(int j=0; j<wdth; j++) {
              int colormapIndex = bytes[offset+wdth*i+j] & 0xFF - colormapOrigin;
              int c = 0xFFFFFFFF;
              if(colormapIndex >= 0) {
                int index = 3*colormapIndex+18;
                int b = palette[index+0] & 0xFF;
                int g = palette[index+1] & 0xFF;
                int r = palette[index+2] & 0xFF;
                int a = 0xFF;
                c = (r<<rs) | (g<<gs) | (b<<bs) | (a<<as);
              }
              pxls[wdth*(hght-i-1)+j] = c;
            }
          }
        }
      }
      break;
    case 32:
      pxls = new int[wdth*hght];
      if((descriptor & RIGHT_ORIGIN) != 0) {
        if((descriptor & UPPER_ORIGIN) != 0) {
          // UpperRight
          for(int i=0; i<hght; i++) {
            for(int j=0; j<wdth; j++) {
              int colormapIndex = bytes[offset+wdth*i+j] & 0xFF - colormapOrigin;
              int c = 0xFFFFFFFF;
              if(colormapIndex >= 0) {
                int index = 4*colormapIndex+18;
                int b = palette[index+0] & 0xFF;
                int g = palette[index+1] & 0xFF;
                int r = palette[index+2] & 0xFF;
                int a = palette[index+3] & 0xFF;
                c = (r<<rs) | (g<<gs) | (b<<bs) | (a<<as);
              }
              pxls[wdth*i+(wdth-j-1)] = c;
            }
          }
        }
        else {
          // LowerRight
          for(int i=0; i<hght; i++) {
            for(int j=0; j<wdth; j++) {
              int colormapIndex = bytes[offset+wdth*i+j] & 0xFF - colormapOrigin;
              int c = 0xFFFFFFFF;
              if(colormapIndex >= 0) {
                int index = 4*colormapIndex+18;
                int b = palette[index+0] & 0xFF;
                int g = palette[index+1] & 0xFF;
                int r = palette[index+2] & 0xFF;
                int a = palette[index+3] & 0xFF;
                c = (r<<rs) | (g<<gs) | (b<<bs) | (a<<as);
              }
              pxls[wdth*(hght-i-1)+(wdth-j-1)] = c;
            }
          }
        }
      }
      else {
        if((descriptor & UPPER_ORIGIN) != 0) {
          // UpperLeft
          for(int i=0; i<hght; i++) {
            for(int j=0; j<wdth; j++) {
              int colormapIndex = bytes[offset+wdth*i+j] & 0xFF - colormapOrigin;
              int c = 0xFFFFFFFF;
              if(colormapIndex >= 0) {
                int index = 4*colormapIndex+18;
                int b = palette[index+0] & 0xFF;
                int g = palette[index+1] & 0xFF;
                int r = palette[index+2] & 0xFF;
                int a = palette[index+3] & 0xFF;
                c = (r<<rs) | (g<<gs) | (b<<bs) | (a<<as);
              }
              pxls[wdth*i+j] = c;
            }
          }
        }
        else {
          // LowerLeft
          for(int i=0; i<hght; i++) {
            for(int j=0; j<wdth; j++) {
              int colormapIndex = bytes[offset+wdth*i+j] & 0xFF - colormapOrigin;
              int c = 0xFFFFFFFF;
              if(colormapIndex >= 0) {
                int index = 4*colormapIndex+18;
                int b = palette[index+0] & 0xFF;
                int g = palette[index+1] & 0xFF;
                int r = palette[index+2] & 0xFF;
                int a = palette[index+3] & 0xFF;
                c = (r<<rs) | (g<<gs) | (b<<bs) | (a<<as);
              }
              pxls[wdth*(hght-i-1)+j] = c;
            }
          }
        }
      }
      break;
    default:
      throw new IOException("Unsupported depth:"+depth);
    }
    return pxls;
  }
  
  private static int [] createPixelsFromRGB(int wdth, int hght, int depth, byte [] bytes, int offset, int descriptor, Order order) throws IOException {
    int [] pxls = null;
    int rs = order.redShift;
    int gs = order.greenShift;
    int bs = order.blueShift;
    int as = order.alphaShift;
    switch(depth) {
    case 24:
      pxls = new int[wdth*hght];
      if((descriptor & RIGHT_ORIGIN) != 0) {
        if((descriptor & UPPER_ORIGIN) != 0) {
          // UpperRight
          for(int i=0; i<hght; i++) {
            for(int j=0; j<wdth; j++) {
              int index = offset+3*wdth*i+3*j;
              int b = bytes[index+0] & 0xFF;
              int g = bytes[index+1] & 0xFF;
              int r = bytes[index+2] & 0xFF;
              int a = 0xFF;
              pxls[wdth*i+(wdth-j-1)] = (r<<rs) | (g<<gs) | (b<<bs) | (a<<as);
            }
          }
        }
        else {
          // LowerRight
          for(int i=0; i<hght; i++) {
            for(int j=0; j<wdth; j++) {
              int index = offset+3*wdth*i+3*j;
              int b = bytes[index+0] & 0xFF;
              int g = bytes[index+1] & 0xFF;
              int r = bytes[index+2] & 0xFF;
              int a = 0xFF;
              pxls[wdth*(hght-i-1)+(wdth-j-1)] = (r<<rs) | (g<<gs) | (b<<bs) | (a<<as);
            }
          }
        }
      }
      else {
        if((descriptor & UPPER_ORIGIN) != 0) {
          // UpperLeft
          for(int i=0; i<hght; i++) {
            for(int j=0; j<wdth; j++) {
              int index = offset+3*wdth*i+3*j;
              int b = bytes[index+0] & 0xFF;
              int g = bytes[index+1] & 0xFF;
              int r = bytes[index+2] & 0xFF;
              int a = 0xFF;
              pxls[wdth*i+j] = (r<<rs) | (g<<gs) | (b<<bs) | (a<<as);
            }
          }
        }
        else {
          // LowerLeft
          for(int i=0; i<hght; i++) {
            for(int j=0; j<wdth; j++) {
              int index = offset+3*wdth*i+3*j;
              int b = bytes[index+0] & 0xFF;
              int g = bytes[index+1] & 0xFF;
              int r = bytes[index+2] & 0xFF;
              int a = 0xFF;
              pxls[wdth*(hght-i-1)+j] = (r<<rs) | (g<<gs) | (b<<bs) | (a<<as);
            }
          }
        }
      }
      break;
    case 32:
      pxls = new int[wdth*hght];
      if((descriptor & RIGHT_ORIGIN) != 0) {
        if((descriptor & UPPER_ORIGIN) != 0) {
          // UpperRight
          for(int i=0; i<hght; i++) {
            for(int j=0; j<wdth; j++) {
              int index = offset+4*wdth*i+4*j;
              int b = bytes[index+0] & 0xFF;
              int g = bytes[index+1] & 0xFF;
              int r = bytes[index+2] & 0xFF;
              int a = bytes[index+3] & 0xFF;
              pxls[wdth*i+(wdth-j-1)] = (r<<rs) | (g<<gs) | (b<<bs) | (a<<as);
            }
          }
        }
        else {
          // LowerRight
          for(int i=0; i<hght; i++) {
            for(int j=0; j<wdth; j++) {
              int index = offset+4*wdth*i+4*j;
              int b = bytes[index+0] & 0xFF;
              int g = bytes[index+1] & 0xFF;
              int r = bytes[index+2] & 0xFF;
              int a = bytes[index+3] & 0xFF;
              pxls[wdth*(hght-i-1)+(wdth-j-1)] = (r<<rs) | (g<<gs) | (b<<bs) | (a<<as);
            }
          }
        }
      }
      else {
        if((descriptor & UPPER_ORIGIN) != 0) {
          // UpperLeft
          for(int i=0; i<hght; i++) {
            for(int j=0; j<wdth; j++) {
              int index = offset+4*wdth*i+4*j;
              int b = bytes[index+0] & 0xFF;
              int g = bytes[index+1] & 0xFF;
              int r = bytes[index+2] & 0xFF;
              int a = bytes[index+3] & 0xFF;
              pxls[wdth*i+j] = (r<<rs) | (g<<gs) | (b<<bs) | (a<<as);
            }
          }
        }
        else {
          // LowerLeft
          for(int i=0; i<hght; i++) {
            for(int j=0; j<wdth; j++) {
              int index = offset+4*wdth*i+4*j;
              int b = bytes[index+0] & 0xFF;
              int g = bytes[index+1] & 0xFF;
              int r = bytes[index+2] & 0xFF;
              int a = bytes[index+3] & 0xFF;
              pxls[wdth*(hght-i-1)+j] = (r<<rs) | (g<<gs) | (b<<bs) | (a<<as);
            }
          }
        }
      }
      break;
    default:
      throw new IOException("Unsupported depth:"+depth);
    }
    return pxls;
  }
  
  private static int [] createPixelsFromGrayscale(int wdth, int hght, int depth, byte [] bytes, int offset, int descriptor, Order order) throws IOException {
    int [] pxls = null;
    int rs = order.redShift;
    int gs = order.greenShift;
    int bs = order.blueShift;
    int as = order.alphaShift;
    switch(depth) {
    case 8:
      pxls = new int[wdth*hght];
      if((descriptor & RIGHT_ORIGIN) != 0) {
        if((descriptor & UPPER_ORIGIN) != 0) {
          // UpperRight
          for(int i=0; i<hght; i++) {
            for(int j=0; j<wdth; j++) {
              int e = bytes[offset+wdth*i+j] & 0xFF;
              int a = 0xFF;
              pxls[wdth*i+(wdth-j-1)] = (e<<rs) | (e<<gs) | (e<<bs) | (a<<as);
            }
          }
        }
        else {
          // LowerRight
          for(int i=0; i<hght; i++) {
            for(int j=0; j<wdth; j++) {
              int e = bytes[offset+wdth*i+j] & 0xFF;
              int a = 0xFF;
              pxls[wdth*(hght-i-1)+(wdth-j-1)] = (e<<rs) | (e<<gs) | (e<<bs) | (a<<as);
            }
          }
        }
      }
      else {
        if((descriptor & UPPER_ORIGIN) != 0) {
          // UpperLeft
          for(int i=0; i<hght; i++) {
            for(int j=0; j<wdth; j++) {
              int e = bytes[offset+wdth*i+j] & 0xFF;
              int a = 0xFF;
              pxls[wdth*i+j] = (e<<rs) | (e<<gs) | (e<<bs) | (a<<as);
            }
          }
        }
        else {
          // LowerLeft
          for(int i=0; i<hght; i++) {
            for(int j=0; j<wdth; j++) {
              int e = bytes[offset+wdth*i+j] & 0xFF;
              int a = 0xFF;
              pxls[wdth*(hght-i-1)+j] = (e<<rs) | (e<<gs) | (e<<bs) | (a<<as);
            }
          }
        }
      }
      break;
    case 16:
      pxls = new int[wdth*hght];
      if((descriptor & RIGHT_ORIGIN) != 0) {
        if((descriptor & UPPER_ORIGIN) != 0) {
          // UpperRight
          for(int i=0; i<hght; i++) {
            for(int j=0; j<wdth; j++) {
              int e = bytes[offset+2*wdth*i+2*j+0] & 0xFF;
              int a = bytes[offset+2*wdth*i+2*j+1] & 0xFF;
              pxls[wdth*i+(wdth-j-1)] = (e<<rs) | (e<<gs) | (e<<bs) | (a<<as);
            }
          }
        }
        else {
          // LowerRight
          for(int i=0; i<hght; i++) {
            for(int j=0; j<wdth; j++) {
              int e = bytes[offset+2*wdth*i+2*j+0] & 0xFF;
              int a = bytes[offset+2*wdth*i+2*j+1] & 0xFF;
              pxls[wdth*(hght-i-1)+(wdth-j-1)] = (e<<rs) | (e<<gs) | (e<<bs) | (a<<as);
            }
          }
        }
      }
      else {
        if((descriptor & UPPER_ORIGIN) != 0) {
          // UpperLeft
          for(int i=0; i<hght; i++) {
            for(int j=0; j<wdth; j++) {
              int e = bytes[offset+2*wdth*i+2*j+0] & 0xFF;
              int a = bytes[offset+2*wdth*i+2*j+1] & 0xFF;
              pxls[wdth*i+j] = (e<<rs) | (e<<gs) | (e<<bs) | (a<<as);
            }
          }
        }
        else {
          // LowerLeft
          for(int i=0; i<hght; i++) {
            for(int j=0; j<wdth; j++) {
              int e = bytes[offset+2*wdth*i+2*j+0] & 0xFF;
              int a = bytes[offset+2*wdth*i+2*j+1] & 0xFF;
              pxls[wdth*(hght-i-1)+j] = (e<<rs) | (e<<gs) | (e<<bs) | (a<<as);
            }
          }
        }
      }
      break;
    default:
      throw new IOException("Unsupported depth:"+depth);
    }
    return pxls;
  }
  
  private TGAReader() {}
  
  private static final class Order {
    Order(int redShift, int greenShift, int blueShift, int alphaShift) {
      this.redShift = redShift;
      this.greenShift = greenShift;
      this.blueShift = blueShift;
      this.alphaShift = alphaShift;
    }
    public int redShift;
    public int greenShift;
    public int blueShift;
    public int alphaShift;
  }
  
}
