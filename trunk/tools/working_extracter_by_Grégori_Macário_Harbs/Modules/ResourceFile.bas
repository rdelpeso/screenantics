#include once "windows.bi"

#include "Compression.bas"
#include "..\Include\Structs.bas"
#include once "crt.bi"

#ifndef AddResInfo
#define AddResInfo(sString) puts(sString & !"\r\n")
#endif

namespace Resource

  function ReadString(pData as any ptr,byref iOffs as integer,iSize as integer=0) as string
    var sTemp = *cptr(zstring ptr,pData+iOffs)
    if iSize then iOffs += (iSize+1) else iOffs += len(sTemp)+1
    return sTemp
  end function
  function ReadShort(pData as any ptr,byref iOffs as integer) as short
    function = *cptr(short ptr,pData+iOffs)
    iOffs += 2
  end function
  function ReadLong(pData as any ptr,byref iOffs as integer) as integer
    function = *cptr(long ptr,pData+iOffs)
    iOffs += 4
  end function

  dim shared pResData as any ptr, iResSize as integer
  dim shared as string sResourceFile
  
  function CreateIndex(sResMap as string) as integer
  
    dim as integer iSz,Isz2
    dim as any ptr pIndex,pData
    
    var f = Freefile()
    open sResMap for binary access read as #f
    iSz=lof(f) : pIndex = allocate(iSz)
    get #f,1,*cptr(ubyte ptr,pIndex),iSz
    close #f
    
    var iOffs = 6
    sResourceFile = Resource.ReadString(pIndex,iOffs)
    var iResourceCount = Resource.ReadShort(pIndex,iOffs)
    
    redim tResource(iResourceCount-1) as ResourceItemStruct
    AddResInfo("["+sResourceFile+"] (" & iResourceCount & " Files)")
    
    if open(sResourceFile for binary access read as #f) then
      messagebox(null,"Failed to open: \r\n'"+sResourceFile+"'", _
      "Resource Viewer",MB_ICONSTOP or MB_SYSTEMMODAL)
      end
    end if
    iSz2=lof(f) : pData = allocate(iSz2)
    get #f,1,*cptr(ubyte ptr,pData),iSz2
    close #f: pResData = pData  
    iResSize = iSz2
    
    for CNT as integer = 0 to iResourceCount-1
      var iInfo   = Resource.ReadLong(pIndex,iOffs)
      var iOffset = Resource.ReadLong(pIndex,iOffs)  
      with tResource(CNT)
        var iTemp = iOffset
        .iOffset = iOffset
        .zName = Resource.ReadString(pData,iTemp,16)
        .lType = Resource.ReadLong(pData,iTemp)
      end with
    next CNT
    
    deallocate(pIndex)
    return iResourceCount
    
  end function
  function Load(iRes as integer) as tResANY ptr
    if iRes < 0 or iRes > ubound(tResource) then return 0
    var pData = pResData+tResource(iRes).iOffset+17
    var iOffs = 0, lType = tResource(iRes).lType    
    dim iImgCnt as integer, pImgSz as ushort ptr
    dim as integer iWid,iHei,iOffsEnd = iResSize
    dim as any ptr pResu
    if iRes < ubound(tResource) then iOffsEnd = tResource(iRes+1).iOffset    
    do while iOffs < ioffsEnd
      select case cptr(StructANY ptr,pData+iOffs)->_lTag
      case cvi("BMP:") 'First TAG of a .bmp resource    
        with *cptr(StructBMP ptr,pData+iOffs)
          if (._hFlags and &h8000) then iOffsEnd = iOffs+._hSize+sizeof(StructANY)
          AddResInfo(space$(iif(._hFlags and &h8000,0,2))+mki$(._lTag))
          AddResInfo(!"\tSize=" & ._hSize & !"\tFlags=" & hex$(._hFlags,4))
          iOffs += sizeof(StructBMP)
          tResource(iRes).lType = ._lTag
        end with
      case cvi("SCR:") 'First TAG of a .scr resource    
        with *cptr(StructSCR ptr,pData+iOffs)
          if (._hFlags and &h8000) then iOffsEnd = iOffs+._hSize+sizeof(StructANY)
          AddResInfo(space$(iif(._hFlags and &h8000,0,2))+mki$(._lTag))
          AddResInfo(!"\tSize=" & ._hSize & !"\tFlags=" & hex$(._hFlags,4))
          iOffs += sizeof(StructSCR)
          tResource(iRes).lType = ._lTag
        end with
      case cvi("PAL:") 'First TAG of a .pal resource    
        with *cptr(StructPAL ptr,pData+iOffs)
          if (._hFlags and &h8000) then iOffsEnd = iOffs+._hSize+sizeof(StructANY)
          AddResInfo(space$(iif(._hFlags and &h8000,0,2))+mki$(._lTag))
          AddResInfo(!"\tSize=" & ._hSize & !"\tFlags=" & hex$(._hFlags,4))
          iOffs += sizeof(StructPAL)
          tResource(iRes).lType = ._lTag
        end with
      case cvi("VGA:") 'Palette Binary Data (.bmp/.pal) 
        with *cptr(StructVGA ptr,pData+iOffs)
          if (._hFlags and &h8000) then iOffsEnd = iOffs+._hSize+sizeof(StructANY)
          AddResInfo(space$(iif(._hFlags and &h8000,0,2))+mki$(._lTag))
          AddResInfo(!"\tSize=" & ._hSize & !"\tFlags=" & hex$(._hFlags,4))
          var iColors = 16, pData = @.bData, iSize = ._hSize '._hSize\3
          iOffs += ._hSize+sizeof(StructVGA)
          if pResu then 
            AddResInfo(!"\tWarning: Multi-Data")
            'deallocate(pResu):pResu=null
          else
            pResu = allocate(offsetof(tResPal,bData)+iSize)
            with *cptr(tResPal ptr, pResu)
              .lType = tResource(iRes).lType
              .iColorCount = iColors
              memcpy(@.tColors(0),pData,iSize)
            end with
            function = pResu
          end if
        end with
      case cvi("INF:") 'Images inside a .bmp resource   
        with *cptr(StructINF ptr,pData+iOffs)
          AddResInfo(space$(iif(._hFlags and &h8000,0,2))+mki$(._lTag))
          AddResInfo(!"\tSize=" & ._hSize & !"\tFlags=" & hex$(._hFlags,4))
          iImgCnt = .hImages: pImgSz = @.iWidHei
          AddResInfo(!"\tImages: " & iImgCnt)          
          var sLine = ""
          for CNT as integer = 0 to iImgCnt-1        
            var iW = pImgSz[CNT], iH = pImgSz[CNT+iImgCnt]
            sLine += !"\t#" & CNT & " " & iW & "x" & iH' & ")"
            if (CNT and 1) then AddResInfo(sLine): sLine = ""            
          next CNT
          if len(sLine) then AddResInfo(sLine): sLine = ""
          iOffs += ._hSize+sizeof(StructANY)
        end with
      case cvi("DIM:") 'Dimensions of a .scr resource   
        with *cptr(StructDIM ptr,pData+iOffs)
          if (._hFlags and &h8000) then iOffsEnd = iOffs+._hSize+sizeof(StructANY)
          AddResInfo(space$(iif(._hFlags and &h8000,0,2))+mki$(._lTag))
          AddResInfo(!"\tSize=" & ._hSize & !"\tFlags=" & hex$(._hFlags,4))
          AddResInfo("    Dimension: " & .hWidth & "x" & .hHeight)
          iWid = .hWidth : iHei = .hHeight
          iOffs += ._hSize+sizeof(StructANY)
        end with
      case cvi("BIN:") 'Compressed Data (.bmp/.scr)     
        with *cptr(StructBIN ptr,pData+iOffs)
          if (._hFlags and &h8000) then iOffsEnd = iOffs+._hSize+sizeof(StructANY)
          AddResInfo(space$(iif(._hFlags and &h8000,0,2))+mki$(._lTag))
          AddResInfo(!"\tSize=" & ._hSize & !" \tFlags=" & hex$(._hFlags,4))
          AddResInfo(!"\tImageSize:" & .lRawSize & !"\tMethod:" & .bMethod)
          iOffs += ._hSize+sizeof(StructANY)          
          if .bMethod <> cmLZW then
            AddResInfo("Unknown Compression Method: " & .bMethod)
            return null
          end if          
          var pOutput = allocate(.lRawSize*2)
          var pInput = cast(ubyte ptr,@.bData)
          var iInSize = ._hsize
          var iOutSize = .lRawSize    
          var iResu = lzw.Unpack(pOutput,iOutSize,pInput,iInSize)
          if iResu <= 0 then
            if iResu >= lbound(lzw.pzError) and iResu <= ubound(lzw.pzError) then
              AddResInfo("Failed to decode with error: '" & *(lzw.pzError(iResu)) & "'")
            else
              AddResInfo("Failed to decode with error: 0x"+hex$(iResu,4))
            end if
            deallocate(pOutput)
          else
            if pResu then 
              AddResInfo(!"\tWarning: Multi-Data")
              deallocate(pResu):pResu=null
            end if
            AddResInfo(!"\tUnpacked " & iResu & " Bytes")
            pOutput = reallocate(pOutput,iResu)                        
            select case tResource(iRes).lType
            case cvi("BMP:") 'Bitmap multiple images
              if iImgCnt then
                var iSz = offsetof(tResBMP,bData)+sizeof(tResBMP_Image)*iImgCnt
                pResu = allocate(iSz)
                with *cptr(tResBMP ptr,pResu)
                  var pImage = pOutput
                  .lType = cvi("BMP:")
                  .iImageCount = iImgCnt
                  for CNT as integer = 0 to iImgCnt-1                    
                    with .tImage(CNT)
                     .iWid   = pImgSz[CNT]
                     .iHei   = pImgSz[CNT+iImgCnt]
                     .pImage = pImage
                      pImage += ((((.iWid+1) and (not 1))*.iHei) shr 1)
                    end with
                  next CNT
                end with              
              else
                AddResInfo(!"\tNO IMAGES??")
              end if
            case cvi("SCR:") 'Scr Single Image
              pResu = allocate(sizeof(tResSCR))
              with *cptr(tResSCR ptr,pResu)              
                .lType  = cvi("SCR:")
                .iWid   = iWid
                .iHei   = iHei
                .pImage = pOutput
              end with
            case else
              AddResInfo(!"\tNO PREVIEW AVALIABLE!")              
              if pOutput then deallocate(pOutput)
            end select
            function = pResu
          end if
        end with
      case else        'Unknown??                       
        var lTag = cptr(StructANY ptr,pData+iOffs)->_lTag, lTag2 = lTag
        if (lTag2 and &h000000FF) = 0 then lTag2 = 0
        if (lTag2 and &h0000FF00) = 0 then lTag2 = 0
        if (lTag2 and &h00FF0000) = 0 then lTag2 = 0
        if (lTag2 and &hFF000000) = 0 then lTag2 = 0
        if (lTag and &h80808080) orelse lTag2=null then
          AddResInfo("BAD UNKNOWN TAG - 0x"+hex$(cint(lTag),8))
          exit do
        else
          with *cptr(StructANY ptr,pData+iOffs)            
            AddResInfo(space$(iif(._hFlags and &h8000,0,2))+mki$(._lTag)+" (UNKNOWN)")
            AddResInfo(!"\tSize=" & ._hSize & !"\tFlags=" & hex$(._hFlags,4))
            if (._hFlags and &h8000) then
              iOffsEnd = iOffs+._hSize+sizeof(StructANY)
              iOffs += sizeof(StructANY)
            else
              iOffs += ._hSize+sizeof(StructANY) 'Structure specific?
            end if
          end with
        end if
      end select
    loop
  end function
  function LoadByName(sName as string) as tResANY ptr
    for CNT as integer = 0 to ubound(tResource)
      if trim$(lcase$(sName)) = trim$(lcase$(tResource(CNT).zName)) then
        return Resource.Load(CNT)
      end if
    next CNT
    return null
  end function
  sub Free(pRes as tResANY ptr)
    if pRes = null then exit sub
    select case *cast(ulong ptr,pRes)
    case cvi("PAL:")
      deallocate(pRes)
    case cvi("SCR:")
      with *cptr(tResSCR ptr,pRes)
       if .pImage then deallocate(.pImage)
       deallocate(pRes)
      end with
    case cvi("BMP:")
      with *cptr(tResBMP ptr,pRes)
        if .tImage(0).pImage then deallocate(.tImage(0).pImage)
        deallocate(pRes)
      end with
    case else
      '???
    end select
  end sub    
  
end namespace


