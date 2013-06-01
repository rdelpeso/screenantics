#define fbc -s gui Res\ResourceViewerGui.rc

#include once "windows.bi"
#include once "win\commctrl.bi"
#include once "win\commdlg.bi"

declare sub AddResInfo(sString as string)
declare sub UpdateResView(pRes as any ptr)
declare function AskSaveFile(sFile as string,sDirOut as string) as string

#include "Modules\BmpOutput.bas"
#include "Modules\ResourceFile.bas"
#ifndef GdiTransparentBlt
declare function TransparentBlt lib "msimg32" alias "TransparentBlt"  (as hdc,as long,as long,as long,as long,as hdc,as long,as long,as long,as long,as ulong) as integer
#endif

'*************** Enumerating our control id's ***********
enum WindowControls
  wcMain
  wcComboFiles
  wcStaticPreview
  wcButtonExport
  wcButtonExportAll
  wcButtonPreview    
  wcEditInfo
  wcStaticZoom
  wcRadioZoom1
  wcRadioZoom2  
  wcRadioZoom3
  wcListInfo
  wcLast
end enum

dim shared as hwnd CTL(wcLast)       'controls
dim shared as hfont MyFont,LitFont,MedFont 'fonts
dim shared as string sAppName,sFileA,sFileB
dim shared as hinstance APPINSTANCE
dim shared as hBrush PatBrush
dim shared ImageDC as hDC,ImageBMP as hBitmap
dim shared as integer iSelResource = -1,ImageCNT
dim shared as integer ImageWid=1,ImageHei=1,IgnoreInfo
dim shared as integer BmpWarn=0
dim shared as ulong lJohnPal(255)
dim shared as any ptr OrgEditProc
dim shared as SMALL_RECT tEdge(1023)
dim shared as string sResDir,sResDataFile

const WM_LoadResourceFile = WM_USER+&h100
const WM_SaveAllResources = WM_USER+&h101

APPINSTANCE = GetModuleHandle(null)
sAppName = "Johnny CastAway Resource Viewer"

declare sub WinMain()
WinMain()

' *************** Procedure Function ****************
function EditProc( hWnd as HWND, msg as UINT, wParam as WPARAM, lParam as LPARAM ) as LRESULT
  const SIF_FLAGS = SIF_POS or SIF_DISABLENOSCROLL
  select case msg
  static as integer iMX,iMY,iMB
  case WM_RBUTTONDOWN,WM_RBUTTONUP
    return 0  
  case WM_SETCURSOR    
    HideCaret(hwnd)
  case WM_MOUSEMOVE
    if iMB then
      var iX = cint(cshort(LOWORD(lParam)))
      var iY = cint(cshort(HIWORD(lParam)))
      if abs(iX-iMX) >= 8 then        
        dim as SCROLLINFO TempScroll = any
        TempScroll = type(sizeof(ScrollInfo),SIF_POS or SIF_RANGE or SIF_PAGE)
        GetScrollInfo( hwnd , SB_HORZ , @TempScroll )
        var iMax = TempScroll.nMax-TempScroll.nPage
        var iNewPos = ((TempScroll.nPos+(iMX-iX))+4) and (not 7)
        if iNewPos < TempScroll.nMin then iNewPos = TempScroll.nMin
        if iNewPos > iMax then iNewPos = iMax
        TempScroll = type(sizeof(ScrollInfo),SIF_POS,0,0,0,iNewPos,iNewPos)
        SetScrollInfo( hwnd , SB_HORZ , @TempScroll , true )
        InvalidateRect( hwnd , null , True )
        iMX += ((iX-iMX) and (not 7))
      end if
      if abs(iY-iMY) >= 8 then
        dim as SCROLLINFO TempScroll = any
        TempScroll = type(sizeof(ScrollInfo),SIF_POS or SIF_RANGE or SIF_PAGE)
        GetScrollInfo( hwnd , SB_VERT , @TempScroll )
        var iMax = TempScroll.nMax-TempScroll.nPage
        var iNewPos = ((TempScroll.nPos+(iMY-iY))+4) and (not 7)
        if iNewPos < TempScroll.nMin then iNewPos = TempScroll.nMin
        if iNewPos > iMax then iNewPos = iMax
        TempScroll = type(sizeof(ScrollInfo),SIF_POS,0,0,0,iNewPos,iNewPos)
        SetScrollInfo( hwnd , SB_VERT , @TempScroll , true )
        InvalidateRect( hwnd , null , True )
        iMY += ((iY-iMY) and (not 7))
      end if
    end if
  case WM_LBUTTONDOWN
    iMX = cint(cshort(LOWORD(lParam)))
    iMY = cint(cshort(HIWORD(lParam)))
    iMB = 1
    function = CallWindowProc(OrgEditProc,hWnd,msg,wParam,lParam)
    HideCaret(hwnd)
    exit function
  case WM_LBUTTONUP
    iMX = -1: iMY = -1: iMB = 0
  case WM_MOUSEWHEEL
    static iDelta as integer    
    iDelta += cint(cshort(HIWORD(wParam)))
    while abs(iDelta) >= WHEEL_DELTA  
      var iZoom = iif( SendMessage( CTL(wcRadioZoom2) , BM_GETCHECK , 0 , 0 ) , 1 , 0 )
      iZoom += iif( SendMessage( CTL(wcRadioZoom3) , BM_GETCHECK , 0 , 0 ) , 2 , 0 )
      iZoom += sgn(iDelta) : iDelta -= sgn(iDelta)*WHEEL_DELTA      
      if iZoom >= 0 and iZoom <= 2 then        
        SendMessage(CTL(wcRadioZoom1+iZoom),WM_LBUTTONDOWN,BST_CHECKED,0)
        SendMessage(CTL(wcRadioZoom1+iZoom),WM_LBUTTONUP  ,BST_CHECKED,0)
        SetFocus(CTL(wcStaticPreview))
      end if
    wend
  case WM_HSCROLL,WM_VSCROLL
    var iPos=cint(HIWORD(wParam)),nScrollCode=cint(LOWORD(wParam)),iType=0
    if msg = WM_HSCROLL then iType = SB_HORZ
    if msg = WM_VSCROLL then iType = SB_VERT      
    dim as SCROLLINFO TempScroll = any
    TempScroll = type(sizeof(ScrollInfo),SIF_POS or SIF_RANGE or SIF_PAGE)
    GetScrollInfo( hwnd , iType , @TempScroll )        
    with TempScroll
      var iMax = .nMax-.nPage
      select case nScrollCode
      case SB_PAGELEFT
        var iDiv = (iMax shr 1)/sqr(iMax)
        var iNewPos = ((.nPos-(iMax\iDiv)+4) and (not 7))
        if iNewPos < .nMin then iNewPos = .nMin
        TempScroll=type(sizeof(ScrollInfo),SIF_FLAGS,0,0,0,iNewPos,iNewPos)
      case SB_PAGERIGHT
        var iDiv = (iMax shr 1)/sqr(iMax)
        var iNewPos = ((.nPos+(iMax\iDiv)+4) and (not 7))
        if iNewPos > iMax then iNewPos = iMax
        TempScroll=type(sizeof(ScrollInfo),SIF_FLAGS,0,0,0,iNewPos,iNewPos)
      case SB_LINELEFT
        var iNewPos = ((.nPos+4) and (not 7))-8
        if iNewPos < .nMin then iNewPos = .nMin
        TempScroll=type(sizeof(ScrollInfo),SIF_FLAGS,0,0,0,iNewPos,iNewPos)
      case SB_LINERIGHT
        var iNewPos = ((.nPos+4) and (not 7))+8
        if iNewPos > iMax then iNewPos = iMax
        TempScroll=type(sizeof(ScrollInfo),SIF_FLAGS,0,0,0,iNewPos,iNewPos)
      case SB_TOP        
        TempScroll=type(sizeof(ScrollInfo),SIF_FLAGS,0,0,0,.nMin,.nMin)
      case SB_BOTTOM                
        TempScroll=type(sizeof(ScrollInfo),SIF_FLAGS,0,0,0,iMax,iMax)
      case SB_THUMBTRACK,SB_THUMBPOSITION	     
        'printf(!"Position %i %i %i\r\n",.nMin,iMax,.nPos)
        iPos = (iPos+4) and (not 7)
        TempScroll=type(sizeof(ScrollInfo),SIF_FLAGS,0,0,0,iPos,iPos)      
      end select
    end with
    SetScrollInfo( hwnd , iType , @TempScroll , True )
    InvalidateRect( hwnd , null , true )
  
  end select
  return CallWindowProc(OrgEditProc,hWnd,msg,wParam,lParam)
end function  
' *********** ALL EVENTS WILL HAPPEN HERE ***********
function WndProc ( hWnd as HWND, msg as UINT, wParam as WPARAM, lParam as LPARAM ) as LRESULT
    
  select case( msg )
  case WM_SaveAllResources 'Export all resources on the list           
    var iAtuRes = wparam, iMaxRes = lparam
    static as integer iResAdd,iFileAdd
    static as double fElapsed
    static as string sFolder
    if iAtuRes = 0 then 
      iResAdd=0:iFileAdd=0:fElapsed=timer
      sFolder = sResDir+sResDataFile+"\"          
      mkdir(sFolder)
    end if
    
    SetWindowText(CTL(wcButtonExportAll),int((iAtuRes*100)\iMaxRes) & "%")
    IgnoreInfo = True
    var pRes = Resource.Load(iAtuRes)
    if pRes then
      select case *cptr(ulong ptr,pRes)
      case cvi("SCR:")
        with *cptr(tResSCR ptr,pRes)              
          var sFile = sFolder+tResource(iAtuRes).zName+".BMP"
          SaveBitmap(sFile,.iWid,-.iHei,4,.pImage,@lJohnPal(1))
          iFileAdd += 1: iResAdd += 1
        end with
      case cvi("BMP:")
        with *cptr(tResBMP ptr,pRes)              
          var sFile = tResource(iAtuRes).zName          
          var iPosi = instr(sFile,".")          
          var sLeft = left$(sFile,iPosi-1)
          var sRight = mid$(sFile,iPosi)          
          for CNT as integer = 0 to .iImageCount-1
            with .tImage(CNT)
              var sNum = "" & CNT : sNum = string$(3-len(sNum),"0")+sNum
              sNum = sLeft+"-"+sNum+sRight
              SaveBitmap(sFolder+sNum,.iWid,-.iHei,4,.pImage,@lJohnPal(1))
              iFileAdd += 1
            end with
          next CNT
          iResAdd += 1                      
        end with
      end select
      Resource.Free(pRes)
    end if
    IgnoreInfo = False
    
    SwitchToThread(): iAtuRes += 1
    if iAtuRes >= iMaxRes then
      SetWindowText(CTL(wcButtonExportAll),"Export ALL")
      for CNT as integer = wcMain+1 to wcLast-1
        EnableWindow(CTL(CNT),True)
      next CNT
      if iSelResource < 0 then EnableWindow(CTL(wcButtonExport),False)
      messagebox(hwnd,iResAdd & " of " & iMaxRes & !" resource(s) were exported.\r\n" _
      "creating a total of " & iFileAdd & !" file(s)\r\n" _
      "the operation took " & csng(timer-fElapsed) & " seconds.", _
      sAppName,MB_ICONINFORMATION or MB_TASKMODAL)
    else
      PostMessage(hwnd,WM_SaveAllResources,iAtuRes,iMaxRes)
    end if
    
  case WM_LoadResourceFile 'Load JohnnyCast Resource file              
    dim as integer iResCount
    dim as string sResFile = "RESOURCE.MAP"
    sResdir = exepath()+"\"
    
    #if 1
    scope ' ***** Asking File to User *****
      dim as zstring*MAX_PATH zFile = "RESOURCE.MAP"
      dim as zstring*MAX_PATH sDir = exepath+"\"
      dim as OPENFILENAME MyOFN = type( _
      sizeof(OPENFILENAME), hwnd , APPINSTANCE , _
      @!"JohnnyCastaway Resource map (*.MAP)\0*.MAP\0\0", _
      null,null,1,@zFile,MAX_PATH,null,null,@sDir, _
      @"Select JohnnyCastAway Resource Map File",OFN_READONLY or _
      OFN_FILEMUSTEXIST or OFN_NOCHANGEDIR or OFN_PATHMUSTEXIST, _
      null,null,null,null,null,null)
      if GetOpenFileName(@MyOFN) = 0 then 
        PostMessage(hwnd,WM_QUIT,0,0): return 0
      end if
      sResFile = *MyOFN.lpstrFile      
      sResDir = left$(sResFile,MYOFN.nFileOffset)      
    end scope
    #endif
    
    scope ' ****** Mapping Resources ******
      AddResInfo(sResFile+" (" & GetCompressedFileSize(sResFile,null) & " bytes)")
      var OldDir = curdir() : chdir sResDir
      iResCount = Resource.CreateIndex(sResFile)        
      AddResInfo(" "+string$(29,"-"))
      chdir OldDir: sResDataFile = Resource.sResourceFile
      for CNT as integer = 0 to len(sResDataFile)
        select case sResDataFile[CNT]
        case asc("a") to asc("z"),asc("A") to asc("Z"),asc("0") to asc("9")
          'nothing
        case else
          sResDataFile[CNT] = asc("_")
        end select
      next CNT
      print sResDataFile
    end scope   
    scope ' ******* Loading Palette *******
      var JohnPal = Resource.LoadByName("JOHNCAST.PAL")
      if JohnPal = null then
        Messagebox(hwnd,!"Failed to locate palette resource JOHNCAST.PAL\r\n" _
        !"\r\nWrong Johnny Castaway resource file was selected?",sAppName, _
        MB_ICONSTOP or MB_APPLMODAL)
        PostMessage(hwnd,WM_CLOSE,0,0)
        return False
      end if      
      with *cptr(tResPAL ptr,JohnPal)
        var fMul = csng(255/63)        
        for CNT as integer = 0 to .iColorCount-1
          with .tColors(CNT)
            .R6 *= fMul : .G6 *= fMul : .B6 *= fMul
            lJohnPal(CNT) = rgba(.R6,.G6,.B6,0)
          end with
        next CNT
      end with
      Resource.Free(JohnPal)
    end scope        
    scope ' **** Enumerating Resources ****
      AddResInfo(" "+string$(29,"-"))
      for CNT as integer = 0 to iResCount-1
        with tResource(CNT)
          var iID = SendMessage(CTL(wcComboFiles),CB_ADDSTRING,null,cint(@.zName))
          SendMessage(CTL(wcComboFiles),CB_SETITEMDATA,iID,CNT)
          AddResInfo(.zName & !"  \t(0x"+hex$(.iOffset,5)+")")
        end with
      next CNT    
    end scope    
    return True
  case WM_SYSCOMMAND       'Block Moving/Size                          
    select case (wparam and &hFFF0)
    case SC_MAXIMIZE,SC_SIZE
      return 0
    end select  
  case WM_CREATE           'Window was created                         
    
    if CTL(wcMain) then return 0    
    CTL(wcMain) = hWnd
    
    dim as Rect TempRect
    dim as integer sx,sy
    GetWindowRect(hwnd,@TempRect)
    sx = TempRect.right-TempRect.Left
    sy = TempRect.Bottom-TempRect.top
    GetClientRect(hwnd,@TempRect)        
    with TempRect
      .right -= .left: .bottom -= .top
      .right += (sx-.right)*2 : .bottom += (sy-.bottom)*2
      SetWindowPos(hwnd,null,null,null,.right,.bottom,SWP_NOMOVE or SWP_NOZORDER)
    end with
    
    'just a macro to help creating controls
    #define CreateControl( mID , mExStyle , mClass , mX , mY , mWid , mHei , mStyle , mCaption ) CTL(mID) = CreateWindowEx(mExStyle,mClass,mCaption,mStyle,mX,mY,mWid,mHei,hwnd,cast(hmenu,mID),APPINSTANCE,null)
    
    const cSimple = WS_CHILD or WS_VISIBLE
    const cButtonStyle = cSimple
    const cEditStyle = cSimple
    const cEditSize = cEditStyle or ES_CENTER or ES_NUMBER
    const cEditFile = cEditStyle or ES_AUTOHSCROLL or ES_CENTER
    const cEditRead = cEditStyle or ES_CENTER 'or ES_READONLY
    const cPushStyle = cSimple or BS_AUTOCHECKBOX	or BS_PUSHLIKE
    const cPreviewStyle = cSimple or WS_VSCROLL or WS_HSCROLL or WS_BORDER or ES_READONLY
    const cComboStyle = cSimple or CBS_AUTOHSCROLL or WS_VSCROLL or _
    CBS_HASSTRINGS or CBS_NOINTEGRALHEIGHT or CBS_DISABLENOSCROLL
    const cLabelStyle = cSimple or SS_CENTERIMAGE
    const cLabelCenter = cLabelStyle or SS_CENTER
    const cLabelRight = cLabelStyle or SS_RIGHT
    const cSplitter = cSimple
    const cTextBox = cSimple or SS_CENTER    
    const cIconStyle = cSimple or SS_ICON
    const cTemp = cSimple or SS_WHITERECT
    const cRadioStyle = cSimple or BS_AUTORADIOBUTTON
    const cCheckStyle = cSimple or BS_AUTOCHECKBOX
    const cRadioFirst = cRadioStyle or WS_GROUP    
    const cListStyle = cSimple or LBS_MULTICOLUMN or LBS_USETABSTOPS or _
    WS_HSCROLL or LBS_NOINTEGRALHEIGHT or LBS_HASSTRINGS or LBS_EXTENDEDSEL
    
    const sEdit = WS_EX_CLIENTEDGE
    const sBord = WS_EX_STATICEDGE
    const sButt = WS_EX_DLGMODALFRAME
    
    var ScrollX = GetSystemMetrics(SM_CXVSCROLL), iSX = 640+ScrollX
    var ScrollY = GetSystemMetrics(SM_CYVSCROLL), iSY = 480+ScrollY
    '860x660
    
    CreateControl( wcComboFiles     , null  , "ComboBox" ,672, 72,180,580, cComboStyle   , "" )
    CreateControl( wcStaticPreview  , null  , "Edit"     ,  8, 8 ,iSX,iSY, cPreviewStyle , "" )
    CreateControl( wcButtonExport   , null  , "Button"   ,672, 8 , 76, 24, cButtonStyle  , "Export" )
    CreateControl( wcButtonExportAll, null  , "Button"   ,756, 8 , 96, 24, cButtonStyle  , "Export ALL" )
    CreateControl( wcStaticZoom     , null  , "Static"   ,672, 40, 52, 24, cLabelStyle   , "Zoom:")
    CreateControl( wcRadioZoom1     , null  , "Button"   ,728, 40, 40, 24, cRadioFirst   , "1x" )
    CreateControl( wcRadioZoom2     , null  , "Button"   ,770, 40, 40, 24, cRadioStyle   , "2x" )
    CreateControl( wcRadioZoom3     , null  , "Button"   ,812, 40, 40, 24, cRadioStyle   , "3x" )
    CreateControl( wcListInfo       , sBord , "ListBox"  , 8 ,512,656,140, cListStyle    , "???" )    
    
    ' **** Creating a font ****
    MyFont = CreateFont(-16,0,0,0,FW_NORMAL,0,0,0,DEFAULT_CHARSET,0,0,0,0,"verdana")
    LitFont = CreateFont(-12,0,0,0,FW_NORMAL,0,0,0,DEFAULT_CHARSET,0,0,0,0,"Courier New")
    MedFont = CreateFont(-24,0,900,0,FW_NORMAL,0,0,0,DEFAULT_CHARSET,0,0,NONANTIALIASED_QUALITY,0,"verdana")
    ' **** Setting this font for all controls ****
    for CNT as integer = wcMain to wcLast-1
      SendMessage(CTL(CNT),WM_SETFONT,cast(wparam,MyFont),false)
    next CNT
    SendMessage(CTL(wcRadioZoom1),WM_SETFONT,cast(wparam,LitFont),false)
    SendMessage(CTL(wcRadioZoom2),WM_SETFONT,cast(wparam,LitFont),false)
    SendMessage(CTL(wcRadioZoom3),WM_SETFONT,cast(wparam,LitFont),false)
    ' **** Setting Default GUI state ****
    SendMessage(CTL(wcRadioZoom1),BM_SETCHECK,BST_CHECKED,0)
    EnableWindow(CTL(wcButtonExport),False)
    
    ' **** Creating TRANSPARENT pattern brush ****
    if PatBrush = 0 then
      type PatternInfo
        bmiheader as BitmapInfoHeader
        bmiColors((16*16)-1) as ulong
      end typE
      #define C1 &h505070
      #define C2 &h585880
      dim as PatternInfo MyPat = type( _
      (sizeof(BitmapInfoHeader),16,16,1,32,BI_RGB), { _
      C1,C1,C1,C1,C1,C1,C1,C1,C2,C2,C2,C2,C2,C2,C2,C2, _
      C1,C1,C1,C1,C1,C1,C1,C1,C2,C2,C2,C2,C2,C2,C2,C2, _
      C1,C1,C1,C1,C1,C1,C1,C1,C2,C2,C2,C2,C2,C2,C2,C2, _
      C1,C1,C1,C1,C1,C1,C1,C1,C2,C2,C2,C2,C2,C2,C2,C2, _
      C1,C1,C1,C1,C1,C1,C1,C1,C2,C2,C2,C2,C2,C2,C2,C2, _
      C1,C1,C1,C1,C1,C1,C1,C1,C2,C2,C2,C2,C2,C2,C2,C2, _
      C1,C1,C1,C1,C1,C1,C1,C1,C2,C2,C2,C2,C2,C2,C2,C2, _
      C1,C1,C1,C1,C1,C1,C1,C1,C2,C2,C2,C2,C2,C2,C2,C2, _
      C2,C2,C2,C2,C2,C2,C2,C2,C1,C1,C1,C1,C1,C1,C1,C1, _
      C2,C2,C2,C2,C2,C2,C2,C2,C1,C1,C1,C1,C1,C1,C1,C1, _
      C2,C2,C2,C2,C2,C2,C2,C2,C1,C1,C1,C1,C1,C1,C1,C1, _
      C2,C2,C2,C2,C2,C2,C2,C2,C1,C1,C1,C1,C1,C1,C1,C1, _
      C2,C2,C2,C2,C2,C2,C2,C2,C1,C1,C1,C1,C1,C1,C1,C1, _
      C2,C2,C2,C2,C2,C2,C2,C2,C1,C1,C1,C1,C1,C1,C1,C1, _
      C2,C2,C2,C2,C2,C2,C2,C2,C1,C1,C1,C1,C1,C1,C1,C1, _
      C2,C2,C2,C2,C2,C2,C2,C2,C1,C1,C1,C1,C1,C1,C1,C1 } )
      PatBrush = CreateDIBPatternBrushPt( cast(any ptr,@MyPat) , DIB_RGB_COLORS	)
    end if    
    
    SendMessage(CTL(wcListInfo),WM_SETFONT,cast(wparam,LitFont),false)
    dim as integer iTabs(...) = {16,16+24*1,16+24*2,16+24*3}
    SendMessage(CTL(wcListInfo),LB_SETTABSTOPS,4,cint(@iTabs(0)))
    SendMessage( CTL(wcListInfo) , LB_SETCOLUMNWIDTH , 656\3 , 0 )    
    OrgEditProc = cast(any ptr,SetWindowLong(CTL(wcStaticPreview),GWL_WNDPROC,cuint(@EditProc)))    
    
    PostMessage(hwnd,WM_LoadResourceFile,0,0)
    
  case WM_COMMAND          'Event happened to a control (child window) 
    select case hiword(wparam)
    case CBN_SELENDCANCEL
      var hWND = cast(hwnd,lparam)
      select case hWND
      case CTL(wcComboFiles)
        EnableWindow(CTL(wcButtonExport),False)
      end select
    case CBN_SELCHANGE',CBN_SELENDOK
      var hcWND = cast(hwnd,lparam)
      select case hcWND
      case CTL(wcComboFiles)
        EnableWindow(CTL(wcButtonExport),True)
        var iIndex = SendMessage(hcWND,CB_GETCURSEL,0,0)
        if iSelResource <> iIndex then
          iSelResource = iIndex
          var iRes = SendMessage(hcWND,CB_GETITEMDATA,iIndex,0)
          with tResource(iRes)
            'Messagebox(hwnd,"Resource Type: '"+mki$(.lType)+"'",.zName,0)
            imageWid=1:ImageHei=1
            SendMessage(CTL(wcListInfo),LB_RESETCONTENT,0,0)
            var pRes = resource.Load(iRes)
            UpdateResView(pRes)
            resource.Free(pRes)
          end with
        end if
      end select
    case BN_CLICKED 'button click
      select case cast(hwnd,lparam)
      case CTL(wcRadioZoom1),CTL(wcRadioZoom2),CTL(wcRadioZoom3)
        InvalidateRect( CTL(wcStaticPreview) , null , true )
      case CTL(wcButtonExportAll)
        var iResu = messagebox(hwnd, _
        !"This operation will export all listed resources as bitmap files\r\n" _
        !"(currently only .bmp and .scr files will be exported) to this folder: \r\n\r\n" _
        "'"+sResDir+sResDataFile+"\"+!"'\r\n\r\n" _
        !"note that BMP resources have multiples images, and each image\r\n" _
        !"will be saved as separate .bmp file applying the '-###' suffix\r\n" _
        !"to the filename.\r\n\r\n\t       Do you want to continue?", _
        sAppName,MB_ICONWARNING or MB_YESNO)
        if iResu = IDYES then          
          var iResCount = ubound(tResource)+1
          for CNT as integer = wcMain+1 to wcLast-1
            EnableWindow(CTL(CNT),false)
          next CNT
          PostMessage(hwnd,WM_SaveAllResources,0,iResCount)
        end if
      case CTL(wcButtonExport)
        IgnoreInfo = True
        var pRes = Resource.Load(iSelResource)
        if pRes = 0 then
          messagebox(hwnd,"This resource can't be exported right now...",sAppName,MB_ICONWARNING)
        else
          select case *cptr(ulong ptr,pRes)
          case cvi("SCR:")
            with *cptr(tResSCR ptr,pRes)              
              var sFile = sResDataFile+"_"+tResource(iSelResource).zName+".BMP",sDir=""
              sFile = AskSaveFile(sFile,sDir)
              if len(sFile) then
                SaveBitmap(sDir+sFile,.iWid,-.iHei,4,.pImage,@lJohnPal(1))
                Messagebox(hwnd,!"Resource Saved as:\r\n\r\n"+sFile,sAppName,MB_ICONINFORMATION)
              end if
            end with
          case cvi("BMP:")
          with *cptr(tResBMP ptr,pRes)              
              var sFile = sResDataFile+"_"+tResource(iSelResource).zName
              var sDir="",iResu=IDYES
              sFile = AskSaveFile(sFile,sDir)
              if len(sFile) then
                var sLeft = "",sRight = ""
                var iPosi = instr(sFile,".")
                if iPosi = 0 then
                  sLeft = sFile: sRight = ".BMP"
                else
                  sLeft = left$(sFile,iPosi-1)
                  sRight = mid$(sFile,iPosi)
                end if
                if .iImageCount > 1 and BmpWarn=0 then                  
                  iResu = Messagebox(hwnd, _
                  !"The Resource you're saving is a multi-image BMP file\r\n" _
                  !"as result multiple .bmp files will be generated using\r\n" _
                  !"\r\n"+sLeft+"-###"+sRight+!"\r\n\r\n" _
                  !"as template for the filenames.\r\n\r\n\r\n" _
                  !"\tDo you want to continue?", _
                  sAppName,MB_ICONASTERISK or MB_YESNO)
                  BmpWarn = 1
                end if
                if iResu = IDYES then
                  var sFiles = !"\r\n"
                  for CNT as integer = 0 to .iImageCount-1
                    with .tImage(CNT)
                      var sNum = "" & CNT : sNum = string$(3-len(sNum),"0")+sNum                      
                      if (CNT and 1)=0 then sFiles += !"\r\n"
                      sNum = sLeft+"-"+sNum+sRight: sFiles += "'"+sNum+!"'\t"                                          
                      SaveBitmap(sDir+sNum,.iWid,-.iHei,4,.pImage,@lJohnPal(1))
                    end with
                  next CNT
                  Messagebox(hwnd,"Resource(s) Saved as:"+sFiles,sAppName,MB_ICONINFORMATION)
                end if
              end if
            end with
          case else
            Messagebox(hwnd,"This resource can't be exported...",sAppName,MB_ICONWARNING)
          end select
          Resource.Free(pRes)
        end if
        IgnoreInfo = False        
      end select      
    end select
  case WM_CTLCOLORLISTBOX  'Background of listbox (ResInfo)            
    var hDC = cast(hdc,wparam), hWND = cast(hwnd,lparam)
    select case hwnd
    case CTL(wcListInfo)    
      SetBkMode(hDC,TRANSPARENT)
      return cuint(GetStockObject(LTGRAY_BRUSH))
    end select
  case WM_CTLCOLORSTATIC   'Background of Preview area                 
    var hDC = cast(hdc,wparam), hcWND = cast(hwnd,lparam)
    select case hcWND
    case CTL(wcStaticPreview)
      static BackDC as hDC, BackBMP as hbitmap
      if ImageDC = null then 
        ImageDC = CreateCompatibleDC(hDC)
        BackDC = CreateCompatibleDC(hDC)
        BackBMP = CreateCompatibleBitmap(hDC,640,480)
        selectobject(BackDC,BackBMP)
      end if
      FillRect(BackDC,@type(0,0,640,480),PatBrush)
      var iZoom = 1+iif( SendMessage( CTL(wcRadioZoom2) , BM_GETCHECK , 0 , 0 ) , 1 , 0 )
      iZoom += iif( SendMessage( CTL(wcRadioZoom3) , BM_GETCHECK , 0 , 0 ) , 2 , 0 )
      var iX=0,iY=0,iSX=ImageWid*iZoom,ISY=ImageHei*iZoom
      static as integer iOldSX=320,iOldSY=240
      const SIF_FLAGS = SIF_PAGE or SIF_RANGE or SIF_DISABLENOSCROLL or SIF_POS
      if iSX <> iOldSX then          
        var MidPos = GetScrollPos(CTL(wcStaticPreview),SB_HORZ)        
        MidPos = (((MidPos)*(iSX-640))/(iOldSX-640))
        if iOldSx <= 640 then MidPos = (iSX-640)/2        
        dim as SCROLLINFO TempScroll = type( sizeof(ScrollInfo) , _
        SIF_FLAGS , 0 , iSX-1 , 640 ,  MidPos , null )
        SetScrollInfo( CTL(wcStaticPreview) , SB_HORZ , @TempScroll , True )
      end if
      if iSY <> iOldSY then
        var MidPos = GetScrollPos(CTL(wcStaticPreview),SB_VERT)        
        MidPos = (((MidPos)*(iSY-480))/(iOldSY-480))
        if iOldSY <= 480 then MidPos = (iSY-480)/2
        dim as SCROLLINFO TempScroll = type( sizeof(ScrollInfo) , _
        SIF_FLAGS , 0 , iSY-1 , 480 , MidPos , null )
        SetScrollInfo( CTL(wcStaticPreview) , SB_VERT , @TempScroll , True )
      end if
      iOldSX = iSX: iOldSY = iSY
      if ImageBMP then        
        iX = (iX+4) and (not 7): iY = (iY+4) and (not 7) 
        if iSX < 640 then iX = (640-iSX) shr 1
        if iSY < 480 then iY = (480-ISY) shr 1
        if iX = 0 then iX = -GetScrollPos( CTL(wcStaticPreview) , SB_HORZ ) 
        if iY = 0 then iY = -GetScrollPos( CTL(wcStaticPreview) , SB_VERT )
        'print iX,iY,iSX,iSY
        if ImageCNT > 0 then
          SetBkColor(BackDC,&hFFDDBB): setBkMode(BackDC,OPAQUE)
          var hPenDot = CreatePen(PS_DOT,0,&h002288)
          var hOldPen = SelectObject(BackDC,hPenDot)
          var hOldBrush = SelectObject(BackDC,GetStockObject(NULL_BRUSH))
          for CNT as integer = 0 to ImageCNT-1
            var iX1 = (cint(tEdge(CNT).left)*iZoom)+iX+(iZoom-1)
            var iY1 = (cint(tEdge(CNT).top)*iZoom)+iY+(iZoom-1)
            var iX2 = (cint(tEdge(CNT).right)*iZoom)+iX-(iZoom-1)
            var iY2 = (cint(tEdge(CNT).bottom)*iZoom)+iY-(iZoom-1)
            Rectangle(BackDC,iX1,iY1,iX2,iY2)
          next CNT
          DeleteObject(hPenDot) : SelectObject(BackDC,hOldPen)
          SelectObject(BackDC,hOldBrush) : GdiFlush()
        end if
        TransparentBlt(BackDC,iX,iY,iSX,iSY,ImageDC,0,0,ImageWid,ImageHei,&hFF55FF)
      end if 
      BitBlt(hDC,0,0,640,480,BackDC,0,0,SRCCOPY)
      return cuint(GetStockObject(NULL_BRUSH))
      'return cuint(PatBrush)
    end select
  case WM_CLOSE,WM_DESTROY 'Windows was closed/destroyed               
    PostQuitMessage(0) ' to quit
    return 0  
  end select
  
  ' *** if program reach here default predefined action will happen ***
  return DefWindowProc( hWnd, msg, wParam, lParam )
    
end function

sub AddResInfo(sString as string)
  if IgnoreInfo then exit sub
  SendMessage( CTL(wcListInfo) , LB_ADDSTRING , 0 , cint(strptr(sString)) )
end sub

sub UpdateResView(pRes as any ptr)
  ImageCNT = 0
  if ImageBMP then deleteobject(ImageBMP): ImageBMP = null  
  if pRes then
    select case *cptr(ulong ptr,pRes)
    case cvi("BMP:")
      with *cptr(tResBMP ptr,pRes)
        dim as integer iWid,iHei,iMaxHei,iBX,iBY
        dim as integer iPitch,iImgCnt = .iImageCount
        ' Getting Limits of the image group 
        for CNT as integer = 0 to iImgCnt-1
          with .tImage(CNT)
            if .iWid > iWid then iWid = ((.iWid+1) and (not 1))
            if .iHei > iMaxHei then iMaxHei = .iHei
            iHei += .iHei
          end with
        next CNT
        ' Calculating position and squared aspect 
        scope
          var iPix = iWid*iHei,iX=0,iY=4,iXMax=0
          iHei = cint((sqr(iPix*(3/4))))        
          if iMaxHei > iHei then iHei = iMaxHei
          iHei += 8
          for CNT as integer = 0 to iImgCnt-1
            with .tImage(CNT)
              if (iY+.iHei+4) >= iHei then
                iXMax += 4: iY=4: iX = iXMax
              end if          
              if (iX+.iWid+4) >= iXMax then iXMax = (iX+.iWid+4)          
              iY += .iHei+4
            end with
          next CNT
          iPitch = (iXMax+5) and (not 1)
        end scope
        ' Creating Bitmap Buffer 
        ImageWid = iPitch : ImageHei = iHei : ImageCnt = iImgCnt
        dim as BitmapInfo ptr BmpInfo = allocate(sizeof(BitmapInfo)+256*4)        
        BmpInfo->bmiHeader = type( sizeof(BitmapInfoHeader), _
        ImageWid, -ImageHei, 1 , 8 , BI_RGB )                
        lJohnPal(16)=&hFFDDBB:lJohnPal(31)=&h002288:lJohnPal(255)=&hFF55FF
        memcpy(@(BmpInfo->bmiColors(0)),@lJohnPal(0),256*sizeof(RGBQUAD))
        dim as ubyte ptr pScr,pScr2,pScr3
        var hDC = GetDC(CTL(wcStaticPreview))
        SetDIBColorTable(hDC,0,256,cast(any ptr,@lJohnPal(0)))
        ImageBMP = CreateDIBSection(hDC,BmpInfo,DIB_RGB_COLORS,@pScr3,null,0)
        SetDIBColorTable(ImageDC,0,256,cast(any ptr,@lJohnPal(0)))
        SelectObject(ImageDC,ImageBMP)
        GdiFlush()
        ' Drawing Border Lines 
        scope
          memset(pScr3,255,ImageWid*ImageHei) 'Clean Background
          'SetBkColor(ImageDC,&hFFDDBB): setBkMode(ImageDC,OPAQUE)
          'var hPenDot = CreatePen(PS_DOT,0,&h002288)
          'var hOldPen = SelectObject(ImageDC,hPenDot)
          'var hOldBrush = SelectObject(ImageDC,GetStockObject(NULL_BRUSH))
          'rectangle(ImageDC,0,0,ImageWid,ImageHei)
          var iX=0,iY=4,iXMax=0
          for CNT as integer = 0 to iImgCnt-1
            with .tImage(CNT)              
              if (iY+.iHei+4) > iHei then iXMax += 0: iY=4: iX = iXMax 
              if (iX+.iWid+4) >= iXMax then iXMax = (iX+.iWid+4)
              var iTX = iX+.iWid+5, iTY = iY+.iHei+4: iY = iTY
              if iTX > iBX then iBX = iTX
              if iTY > iBY then iBY = iTY
            end with
          next CNT          
          iBX = (ImageWid-iBX) shr 1: if iBX < 0 then iBX = 0
          iBY = (ImageHei-iBY) shr 1: if iBY < 0 then iBY = 0
          iX=0 : iY=4 : iXMax=0
          for CNT as integer = 0 to iImgCnt-1
            with .tImage(CNT)              
              if (iY+.iHei+4) > iHei then iXMax += 0: iY=4: iX = iXMax              
              if (iX+.iWid+4) >= iXMax then iXMax = (iX+.iWid+4)
              tEdge(CNT).left   = iX+3+iBX
              tEdge(CNT).top    = iY-1+iBY
              tEdge(CNT).right  = iX+.iWid+5+iBX 
              tEdge(CNT).bottom = iY+.iHei+1+iBY
              'rectangle(ImageDC,iX+3+iBX,iY-1+iBY,iX+.iWid+5+iBX,iY+.iHei+1+iBY)
              iY += .iHei+4              
            end with
          next CNT
          'DeleteObject(hPenDot)
          'SelectObject(ImageDC,hOldPen)
          'SelectObject(ImageDC,hOldBrush)
          'GdiFlush()
        end scope 
        ' Drawing Images 
        scope
          var pScr2 = cptr(ubyte ptr,pScr3)+iPitch*(4+iBY)+4+iBX
          var pScr = pScr2, iYMax = 4, iWMax = 0 
          var pPix = cast(ubyte ptr,.tImage(0).pImage)
          for CNT as integer = 0 to iImgCnt-1
            var iW = (.tImage(CNT).iWid+1) and (not 1)
            var iH = .tImage(CNT).iHei
            if (iYMax+iH+4) > iHei then
              iYMax=4: pScr2 += iWMax+4
              pScr = pScr2: iWMax = 0
            end if  
            var iY = iYMax
            for CN2 as integer = CNT to iImgCnt-1
              var iW2 = (.tImage(CN2).iWid+1) and (not 1)
              var iH2 = .tImage(CN2).iHei
              if (iH2+iY+4) > iHei then exit for
              if iW2 > iWMax then iWMax = iW2
              iY += iH2+4
            next CN2
            for Y as integer = 0 to iH-1
              for X as integer = 0 to (iW shr 1)-1
                var iPixA = (*pPix) shr 4
                var iPixB = (*pPix) and 15
                if iPixA then pScr[0] = iPixA
                if iPixB then pScr[1] = ipixB
                pScr += 2: pPix += 1
              next X
              pScr += iPitch-iW
            next Y    
            iYMax += iH+4: pScr += iPitch*4
          next CNT  
        end scope
        ReleaseDC(CTL(wcStaticPreview),hDC)
      end with
    case cvi("SCR:")
      with *cptr(tResSCR ptr,pRes)
        ImageWid = .iWid : ImageHei = .iHei
        var hDC = GetDC(CTL(wcStaticPreview))
        ImageBMP = CreateCompatibleBitmap(hDC,ImageWid,ImageHei)
        dim as BitmapInfo ptr BmpInfo = allocate(sizeof(BitmapInfo)+256*4)
        BmpInfo->bmiHeader = type( sizeof(BitmapInfoHeader), _
        ImageWid, -ImageHei, 1 , 4 , BI_RGB )         
        memcpy(@(BmpInfo->bmiColors(0)),@lJohnPal(0),256*sizeof(RGBQUAD))
        SetDIBColorTable(ImageDC,0,256,cast(any ptr,@lJohnPal(0)))
        SetDIBits( ImageDC,ImageBMP,0,ImageHei,.pImage,BmpInfo, DIB_RGB_COLORS )        
        SelectObject(ImageDC,ImageBMP)
        ReleaseDC(CTL(wcStaticPreview),hDC)
      end with
    case cvi("PAL:")
      with *cptr(tResPAL ptr,pRes)
        ImageWid = 640 : ImageHei = 480
        var hDC = GetDC(CTL(wcStaticPreview))
        ImageBMP = CreateCompatibleBitmap(hDC,640,480)
        selectObject(ImageDC,ImageBMP)
        var iStep = 640\.iColorCount, fMul = csng(255/63)        
        SelectObject(ImageDC,MedFont)
        SetBkMode(ImageDC,TRANSPARENT)        
        dim as size szText
        var iColors = .iColorCount
        for CNT as integer = 0 to iColors-1          
          with .tColors(CNT)
            var iColor = rgba(.B6*fMul,.G6*fMul,.R6*fMul,0)
            var hColor = CreateSolidBrush( iColor )
            dim as Rect MyRect = type(CNT*iStep,0,(CNT+1)*iStep,479)
            FillRect(ImageDC,@MyRect,hColor)            
            var sText = "#" & CNT            
            GetTextExtentPoint(ImageDC,sText,len(sText),@szText)
            var iX = (CNT*iStep+(iStep shr 1)): iX -= (szText.cy) shr 1
            var iY = cint(szText.cx*1.8)+(((480-(szText.cx*2))*CNT)\iColors)
            SetTextColor(ImageDC,&hD0D0D0)
            for iOY as integer = -1 to 1
              for iOX as integer = -1 to 1                
                TextOut(ImageDC,iX+iOX,iY+iOY,sText,len(sText))                
              next iOX
            next iOY
            SetTextColor(ImageDC,&h303030)
            TextOut(ImageDC,iX,iY,sText,len(sText))
            DeleteObject(hColor)
          end with
        next CNT
        ReleaseDC(CTL(wcStaticPreview),hDC)
      end with        
    case else
      '
    end select
  end if
  InvalidateRect(CTL(wcStaticPreview),null,true)
end sub

function AskSaveFile(sFile as string,sDirOut as string) as string
  dim as zstring*MAX_PATH zFile = sFile
  dim as zstring*MAX_PATH sDir = exepath
  dim as OPENFILENAME MyOFN = type( _
  sizeof(OPENFILENAME), CTL(wcMain) , APPINSTANCE , _
  @!"Bitmap File (*.BMP)\0*.BMP\0\0", _
  null,null,1,@zFile,MAX_PATH,null,null,@sDir, _
  @"Where to save the resource?",_
  OFN_OVERWRITEPROMPT or OFN_NOCHANGEDIR or OFN_PATHMUSTEXIST, _
  null,null,null,null,null,null)
  if GetSaveFileName(@MyOFN) = 0 then return ""    
  var sResFile = *MyOFN.lpstrFile      
  sDirOut = left$(sResFile,MYOFN.nFileOffset)
  return mid$(sResFile,MYOFN.nFileOffset+1)
end function

' *********************************************************************
' *********************** SETUP MAIN WINDOW ***************************
' ******************* This code can be ignored ************************
' *********************************************************************

sub WinMain ()
  
  dim wMsg as MSG
  dim wcls as WNDCLASS
  dim as HWND hWnd  
    
  '' Setup window class  
    
  with wcls
    .style         = CS_HREDRAW or CS_VREDRAW or CS_SAVEBITS
    .lpfnWndProc   = @WndProc
    .cbClsExtra    = 0
    .cbWndExtra    = 0
    .hInstance     = APPINSTANCE
    .hIcon         = LoadIcon( APPINSTANCE, "FB_PROGRAM_ICON" )
    .hCursor       = LoadCursor( NULL, IDC_ARROW )
    .hbrBackground = cast(hBrush, COLOR_BTNFACE + 1) 'official hack!
    .lpszMenuName  = NULL
    .lpszClassName = strptr( sAppName )
  end with
    
  '' Register the window class     
  if( RegisterClass( @wcls ) = FALSE ) then
    MessageBox( null, "Failed to register wcls!", sAppName, MB_ICONERROR )
    exit sub
  end if
    
  '' Create the window and show it
  hWnd = CreateWindowEx(null,sAppName,sAppName+" v0.7 by Mysoft", _
  WS_VISIBLE or WS_TILEDWINDOW, _
  CW_USEDEFAULT,CW_USEDEFAULT,860,660,null,null,APPINSTANCE,NULL)  
  SetforegroundWindow(hWnd)
    
  '' Process windows messages
  ' *** all messages(events) will be read converted/dispatched here ***
  UpdateWindow( hWnd )
  while( GetMessage( @wMsg, NULL, 0, 0 ) <> FALSE )    
    TranslateMessage( @wMsg )
    DispatchMessage( @wMsg )    
  wend    
  
end sub