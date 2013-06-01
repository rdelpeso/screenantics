#include "windows.bi"

sub SaveBitmap(sFileName as string,iWid as integer,iHei as integer,iBPP as integer,pData as any ptr,pPal as any ptr=0)
  select case iBpp
  case 1,2,4,8,16,24,32: '
  case else: exit sub
  end select  
  dim as bitmapfileheader BmpHeader = type(cvshort("BM"),0, _
  null,null,sizeof(bitmapfileheader)+sizeof(bitmapinfo))
  dim as bitmapinfo BmpInfo = type( type(sizeof(BitmapInfoHeader)) , _
  iWid,abs(iHei),1,iBPP,BI_RGB,abs(iWid*iHei*iBpp) shr 3,null,null,null,null)
  if iBpp < 16 then
    BmpInfo.BmiHeader.biClrUsed = (1 shl iBpp)
    BmpHeader.bfOffBits += (1 shl iBpp)*sizeof(ulong)
    if pPal = null then exit sub
  end if
  BmpHeader.bfSize = BmpHeader.bfOffBits+BmpInfo.BmiHeader.biSizeImage  
  var f = freefile()
  if open(sFileName for binary access write as #f) then
    messagebox(null,!"Failed to open\r\n\r\n"+sFileName,"Export",MB_SYSTEMMODAL or MB_ICONERROR)
    exit sub
  end if
  put #f,,BmpHeader
  put #f,,BmpInfo
  if BmpInfo.BmiHeader.biClrUsed then
    put #f,,*cptr(ulong ptr,pPal),(1 shl iBpp)
  end if
  if iHei >=0 then
    put #f,,*cptr(ubyte ptr,pData),BmpInfo.BmiHeader.biSizeImage
  else
    pData += BmpInfo.BmiHeader.biSizeImage
    var iPitch = (iWid*iBpp) shr 3
    for CNT as integer = 1 to abs(iHei)
      pData -= iPitch
      put #f,,*cptr(ubyte ptr,pData),iPitch
    next CNT
  end if
  close #f
end sub