type StructANY field = 1
  _lTag    as ulong  '???:' tag name
  _hSize   as ushort 'Tag Size
  _hFlags  as ushort 'Tag Flags
end type

type StructDIM field=1
  _lTag   as ulong  'DIM:
  _hSize  as ushort 'Tag Size
  _hFlags as ushort 'Tag Flags
  hWidth  as ushort 'Width of Image
  hHeight as ushort 'Height of Image
end type

type StructBIN field = 1
  _lTag    as ulong  'BIN:
  _hSize   as ushort 'Tag Size
  _hFlags  as ushort 'Tag Flags
  bMethod  as ubyte  'Method of compression
  lRawSize as ulong  'Uncompressed Size
  bData    as ubyte  'Start of data
end type

type StructBMP field = 1
  _lTag    as ulong  'BMP:
  _hSize   as ushort 'Tag Size
  _hFlags  as ushort 'Tag Flags
end type

type StructSCR field = 1
  _lTag    as ulong  'SCR:
  _hSize   as ushort 'Tag Size
  _hFlags  as ushort 'Tag Flags
end type

type StructINF field = 1
  _lTag     as ulong  'INF:
  _hSize    as ushort 'Tag Size
  _hFlags   as ushort 'Tag Flags
  hImages   as ushort 'Number of images
  iWidHei   as ushort 'Wid of each image/Hei of each image
end type

type StructPAL field = 1
  _lTag     as ulong  'PAL:
  _hSize    as ushort 'Tag Size
  _hFlags   as ushort 'Tag Flags
end type

type StructVGA field = 1
  _lTag     as ulong  'VGA:
  _hSize    as ushort 'Tag Size
  _hFlags   as ushort 'Tag Flags
  bData     as ubyte  'Start of RGB triplets
end type

'-------------------------------------------------------------

type ResourceItemStruct field=1
  zName   as zstring*16
  iOffset as integer
  lType   as integer
end type
redim shared tResource() as ResourceItemStruct

type tResANY as any ptr
type tResSCR field=1
  lType  as long
  iWid   as integer
  iHei   as integer
  pImage as any ptr
end type
type tResBMP_Image field=1
  iWid   as integer
  iHei   as integer
  pImage as any ptr
end type
type tResBMP field=1
  lType  as long
  iImageCount as integer
  union
    bData as ubyte    
    tImage(65535) as tResBMP_Image
  end union
end type
type tResPAL_Palette field=1
  R6 as ubyte
  G6 as ubyte
  B6 as ubyte
end type
type tResPAL field=1
  lType  as long
  iColorCount as integer
  union
    bData as ubyte    
    tColors(255) as tResPAL_Palette
  end union
end type
