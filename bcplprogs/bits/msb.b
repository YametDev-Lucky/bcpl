// This program tries out various methods to find the most significant
// one in a word.
// Implemented in Cintcode BCPL by Martin Richards (c) Feb 2001

GET "libhdr"

LET start() = VALOF
{ LET t = TABLE //           Cintcode instruction executions
 //  test data      result  msb  msb1 msb2 msb3 msb4 msb5 msb6 msb7 msb8
    #xFFFFFFFF, // 80000000 326   26   55    9    3   21   37   29   17
    #x7FFFFFFF, // 40000000 316   26   50   18   32   21   37   29   17 
    #x87654321, // 80000000 136   26   55    9    3   21   37   29   17 
    #x7FF23456, // 40000000 196   26   50   18   64   21   37   29   17 
    #x12345678, // 10000000 136   26   45   36   64   21   37   29   17 
    #x01234567, // 01000000 126   26   40   72   64   21   37   29   17 
    #x00123456, // 00100000  96   26   40  108   64   21   33   25   17 
    #x00012345, // 00010000  76   26   35  144   64   21   29   21   17 
    #x00001234, // 00001000  56   26   40  180   48   21   25   21   17 
    #x00000123, // 00000100  46   26   35  216   48   21   35   17   17 
    #x00000012, // 00000010  26   26   35  252   32   21   17    9   13 
    #x00000001, // 00000001  16   26   30  288   32   21    9    9   13 
    #xF0F0F0F0, // 80000000 166   26   55    9    3   21   37   29   17 
    #x80808080, // 80000000  46   26   55    9    3   21   37   29   17 
    #x40404040, // 40000000  46   26   50   18   80   21   37   29   17 
    #x20202020, // 20000000  46   26   50   27   80   21   37   29   17 
    #x10101010, // 10000000  46   26   45   36   80   21   37   29   17 
    #x0000FFFF, // 00008000 166   26   50  153   32   21   25   21   17 
    #x00001FFF, // 00001000 136   26   40  180   32   21   25   21   17 
    #x00000000  // 00000000   6    3    3  293   32   21    9    9   13 

  LET w = 0
  LET k = 0
  LET bit = 0

  writef("*nTest various implementations of msb*n*n")

  { w := !t
    t := t+1
    bit := msb(w)
    writef("%x8 %x8", w, bit)
    try(w, msb);  try(w, msb1); try(w, msb2); try(w, msb3)
    try(w, msb4); try(w, msb5); try(w, msb6); try(w, msb7)
    try(w, msb8)
    newline()
  } REPEATWHILE w

  writef("*n*nEnd of test*n")
  RESULTIS 0
}

AND try(w, f) BE
  writef(" %i3%c", instrcount(f, w), msb(w)=f(w) -> ' ', '#')

AND msb(w) = VALOF
{ LET res = 0
  WHILE w DO { res := w & -w; w := w-res }
  RESULTIS res
}

AND msb1(w) = w=0 -> 0, VALOF // Best compromise betweem size and speed
{ w := w | w>>1
  w := w | w>>2
  w := w | w>>4
  w := w | w>>8
  w := w | w>>16
  RESULTIS (w>>1) + 1
}

AND msb2(w) = w=0 -> 0, VALOF
{ LET r, a = 1, ?
  a := w>>16; IF a DO w, r := a, r<<16
  a := w>> 8; IF a DO w, r := a, r<< 8
  a := w>> 4; IF a DO w, r := a, r<< 4
  a := w>> 2; IF a DO w, r := a, r<< 2
  a := w>> 1; IF a DO w, r := a, r<< 1

  RESULTIS r
}

AND msb3(w) = VALOF
{ LET b = #x80000000
  WHILE b DO
  { UNLESS (w&b)=0 RESULTIS b
    b := b>>1
  }
  RESULTIS 0
}

AND msb4(w) = VALOF
{ IF w<0 RESULTIS #x80000000
  w := w | w>>1 | w>>2

  { // Remove least significant block of consecutive ones
    LET r = w & -w     // w=  ...01100111000 r= ...00000001000
    w    := w+r        // w=  ...01101000000 r= ...00000001000
    r    := w & -w     // w=  ...01101000000 r= ...00001000000
    w    := w-r        // w=  ...01100000000 r= ...00001000000
    UNLESS w RESULTIS r>>1
  } REPEAT
}

AND msb5(w) =
 (w&#xffff0000)=0 ->
   (w&#x0000ff00)=0 ->
   (w&#x000000f0)=0 -> (w&#x0000000c)=0 -> (w&#x00000002)=0 ->          w,
                                                               #x00000002,
                                           (w&#x00000008)=0 -> #x00000004,
                                                               #x00000008,
                       (w&#x000000c0)=0 -> (w&#x00000020)=0 -> #x00000010,
                                                               #x00000020,
                                           (w&#x00000080)=0 -> #x00000040,
                                                               #x00000080,
   (w&#x0000f000)=0 -> (w&#x00000c00)=0 -> (w&#x00000200)=0 -> #x00000100,
                                                               #x00000200,
                                           (w&#x00000800)=0 -> #x00000400,
                                                               #x00000800,
                       (w&#x0000c000)=0 -> (w&#x00002000)=0 -> #x00001000,
                                                               #x00002000,
                                           (w&#x00008000)=0 -> #x00004000,
                                                               #x00008000,
   (w&#xff000000)=0 ->
   (w&#x00f00000)=0 -> (w&#x000c0000)=0 -> (w&#x00020000)=0 -> #x00010000,
                                                               #x00020000,
                                           (w&#x00080000)=0 -> #x00040000,
                                                               #x00080000,
                       (w&#x00c00000)=0 -> (w&#x00200000)=0 -> #x00100000,
                                                               #x00200000,
                                           (w&#x00800000)=0 -> #x00400000,
                                                               #x00800000,
   (w&#xf0000000)=0 -> (w&#x0c000000)=0 -> (w&#x02000000)=0 -> #x01000000,
                                                               #x02000000,
                                           (w&#x08000000)=0 -> #x04000000,
                                                               #x08000000,
                       (w&#xc0000000)=0 -> (w&#x20000000)=0 -> #x10000000,
                                                               #x20000000,
                                           (w&#x80000000)=0 -> #x40000000,
                                                               #x80000000


AND msb6(w) = VALOF
{ LET t = TABLE 0,1,2,2,4,4,4,4,8,8,8,8,8,8,8,8

  UNLESS w>> 4 RESULTIS t!w
  UNLESS w>> 8 RESULTIS t!(w>> 4) <<  4
  UNLESS w>>12 RESULTIS t!(w>> 8) <<  8
  UNLESS w>>16 RESULTIS t!(w>>12) << 12
  UNLESS w>>20 RESULTIS t!(w>>16) << 16
  UNLESS w>>24 RESULTIS t!(w>>20) << 20
  UNLESS w>>28 RESULTIS t!(w>>24) << 24
  RESULTIS              t!(w>>28) << 28
}

AND msb7(w) = VALOF
{ LET t = TABLE
        0,  1,  2,  2,  4,  4,  4,  4,  8,  8,  8,  8,  8,  8,  8,  8,
       16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16,
       32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
       32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32

  UNLESS w>> 6 RESULTIS t!w
  UNLESS w>>12 RESULTIS t!(w>> 6) <<  6
  UNLESS w>>18 RESULTIS t!(w>>12) << 12
  UNLESS w>>24 RESULTIS t!(w>>18) << 18
  UNLESS w>>30 RESULTIS t!(w>>24) << 24
  RESULTIS              t!(w>>30) << 30
}

AND msb8(w) = VALOF  // The fastest method
{ LET t = TABLE
        0,  1,  2,  2,  4,  4,  4,  4,  8,  8,  8,  8,  8,  8,  8,  8,
       16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16,
       32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
       32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
       64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
       64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
       64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
       64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
      128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,
      128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,
      128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,
      128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,
      128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,
      128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,
      128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,
      128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128

  //UNLESS w>>8  RESULTIS t!w
  //UNLESS w>>16 RESULTIS t!(w>> 8) <<  8
  //UNLESS w>>24 RESULTIS t!(w>>16) << 16
  //RESULTI(w>>16) << 16S              t!(w>>24) << 24
  TEST w>>16
  THEN TEST w>>24
       THEN RESULTIS t!(w>>24) << 24
       ELSE RESULTIS t!(w>>16) << 16
  ELSE TEST w>>8
       THEN RESULTIS t!(w>> 8) <<  8
       ELSE RESULTIS t!w
}
