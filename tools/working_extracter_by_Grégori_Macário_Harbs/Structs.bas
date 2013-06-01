type StructTAG field = 1
  _lTag    as ulong  '???:' tag name
  _hSize   as ushort 'Tag Size
  _hFlags  as ushort 'Tag Flags
end type

type StructVGA field = 1
  _lTag    as ulong  'VGA: tag name
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

type StructINF field = 1
  _lTag     as ulong  'INF:
  _hSize    as ushort 'Tag Size
  _hFlags   as ushort 'Tag Flags
  hImages   as ushort 'Number of images
  iWidHei   as ushort 'Wid of each image/Hei of each image
end type