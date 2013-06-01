#undef append

enum CompressMethods
  cmUncompress = 0
  cmHuffman    = 1
  cmLZW        = 2
end enum

namespace lzw  
  dim shared as zstring ptr pzError(-4 to 0) = { _ 
  @"Stack Overflow",@"Token Table Overflow", _
  @"Input Data Overflow",@"Output Data Overflow", _
  @"No Data Decompressed." }
  enum DecodeError
    deNoData         =  0
    deOutputOverflow = -1
    deInputOverflow  = -2
    deTableOverflow  = -3
    deStackOverFlow  = -4
  end enum
    
  dim shared as integer nextbit, current, iInputLeft
  dim shared as integer DoExit
  dim shared as any ptr pInput  

  function readByte() as ubyte	
    if lzw.iInputLeft <= 0 then lzw.DoExit = -2: return 0
    lzw.pInput += 1: lzw.iInputLeft -= 1
    return *cptr(ubyte ptr,(lzw.pInput)-1)  
  end function
  
  sub skip(n as integer)
    if lzw.iInputLeft <= 0 then lzw.DoExit = -2: exit sub
    if n > lzw.iInputLeft then n = lzw.iInputLeft
    lzw.pInput += n: lzw.iInputLeft -= n
  end sub
  
  sub SkipBits()    
    if lzw.nextbit > 0 then
      lzw.nextbit = 0    
      lzw.current = readByte()    
    end if
  end sub
  
  function GetBits(n as uinteger) as uinteger
    if n = 0 then return -1
    dim as uinteger x = 0
    for i as uinteger = 0 to n - 1
      if ((lzw.current) and (1 shl (lzw.nextbit))) then
        x += (1 shl i)
      end if
      lzw.nextbit += 1
      if lzw.nextbit > 7 then
        lzw.current = readByte()
        lzw.nextbit = 0
      end if
    next i
    return x
  end function
  
  type CodeTableEntry
    as ushort prefix
    as ubyte  bappend
  end type
  
  function unpack(pdata as ubyte ptr,iDataSz as integer, pSource as any ptr, iSourceSz as integer) as integer
    
    lzw.iInputLeft = iSourceSz
    lzw.pInput = pSource
    lzw.current = readByte()
    lzw.DoExit = 0
    dim as integer posout = 0  
    lzw.nextbit = 0
  
    var codetable = cptr(CodeTableEntry ptr, callocate(sizeof(CodeTableEntry)*4096))
    var decodestack = cptr(ubyte ptr, callocate(sizeof(ubyte)*4096))
    dim as ubyte ptr stackptr = decodestack
    dim as ubyte ptr stackend = decodestack+4096
    dim as uinteger n_bits = 9, free_entry = 257
    dim as uinteger oldcode = GetBits(n_bits)
    dim as uinteger lastbyte = oldcode, bitpos = 0
    
    if posout >= iDataSz then return -1
    pdata[posout] = oldcode: posout += 1    
  
    while lzw.iInputLeft      
      dim as uinteger newcode = GetBits(n_bits)
      bitpos += n_bits
      if newcode = 256 then                            
        var nbits3 = (n_bits shl 3)
        var nSkip = ( (nbits3-((bitpos-1) mod nbits3)) -1 )        
        var Dummy = GetBits( nSkip ) ' <- this is correct
        'skip( nSkip shr 3 ) : SkipBits() '<- this was skipping bytes!
        if DoExit then exit while
        n_bits = 9 : free_entry = 256 : bitpos = 0
      else
        dim as uinteger code = newcode
        if code >= free_entry then
          if stackptr >= stackend then posout = -4: exit while 'error
          *stackptr = lastbyte: stackptr += 1
          code = oldcode
        end if
        while code >= 256
          if code > 4095 then posout = -3: exit while,while 'error
          if stackptr >= stackend then posout = -4: exit while,while 'error
          *stackptr = codetable[code].bappend
          stackptr += 1 : code = codetable[code].prefix
        wend
        if stackptr >= stackend then posout = -4: exit while 'error
        *stackptr = code : stackptr += 1 : lastbyte = code
        while stackptr > decodestack
          stackptr -= 1          
          if stackptr >= stackend then posout = -4: exit while, while 'error
          if posout >= iDataSz then exit while, while          
          pdata[posout] = *stackptr: posout += 1
        wend
        if free_entry < 4096 then
          if free_entry < 0 then posout = -4: exit while 'error
          codetable[free_entry].prefix = oldcode
          codetable[free_entry].bappend = lastbyte
          free_entry += 1
          if (free_entry >= (1UL shl n_bits)) andalso (n_bits < 12) then
            n_bits += 1 : bitpos = 0
          end if
        end if
        oldcode = newcode
      end if
    wend
    if decodestack then deallocate(decodestack): decodestack = 0
    if codetable then deallocate(codetable): codetable = 0 
    if lzw.DoExit then return lzw.DoExit
    return posout
  end function

end namespace