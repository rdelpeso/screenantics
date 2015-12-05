# Structure of Screen Antics Johnny Castaway resource files #

## RESOURCE.MAP file: ##
### Header: ###
| **Size (bytes)** | **Data** |
|:-----------------|:---------|
| 6	               | Unknown header bytes, perhaps version number of map/resource file |
| Variable         | Resource file name (in this case RESOURCE.001, a 0 byte terminated string) |
| 2                | Number of resources (In this case 180) |
| **Repeated resource descriptor records (total of 8 bytes each):** |
| 4                | Unknown bytes, perhaps information about type of resource, compression used or other information |
| 4                | Offset in resource file where data is located|

## RESOURCE.001 file: ##
### Repeated resources: ###
| **Size (bytes)** | **Data** |
|:-----------------|:---------|
| 12               | Name of resource (0 byte terminated) |
| 4                | Not sure but seems to be size of the resource data |
| Variable         | Resource data |

### Resources in RESOURCE.001 ###
| **Resource** | **Offset** | **Unknown** | **Size** |
|:-------------|:-----------|:------------|:---------|
|SA\_DEMO.BMP  |00000000    |53411349     |0000014d  |
|MJJOG.TTM     |0000015e    |4d4a9130     |00001402  |
|MJJOG2.BMP    |	00001571   |	4d4a4286    |00002b82  |
|MJJOG1.BMP    |	00004104   |	4d4a3ecb    |00001c6d  |
|SJWORK.TTM    |	00005d82   |	534abdc5    |00000403  |
|JOFFICE.SCR   |	00006196   |	4a4fb6f6    |000013b8  |
|SJWORK.BMP    |	0000755f   |	534a7e77    |00000fe7  |
|SJMSSGE.TTM   |	00008557   |	5349f339    |0000161f  |
|MJBOTTLE.BMP  |	00009b87   |	4d49db41    |00001ee0  |
|MJBTL2.BMP    |	0000ba78   |	4d4a83d2    |000021f1  |
|THNKBUBL.BMP  |	0000dc7a   |	5447d5c3    |00003336  |
|SJMSUZY.TTM   |	00010fc1   |	534a047e    |00000d97  |
|SJMSUZY1.BMP  |	00011d69   |	534a95e4    |0000108f  |
|SJMSUZY2.BMP  |	00012e09   |	534a997a    |0000213d  |
|SJMSUZY3.BMP  |	00014f57   |	534a9d12    |00003c11  |
|GJVIS5W.TTM   |	00018b79   |	474a01ae    |00000da3  |
|JATA.BMP      |	0001992d   |	4a4133d3    |000003a8  |
|GJVIS52.BMP   |	00019ce6   |	4749d83f    |000026e0  |
|MJCOCO1.TTM   |	0001c3d7   |	4d4a5329    |0000137a  |
|MJCOCO.BMP    |	0001d762   |	4d4a9772    |0000308d  |
|COCOHEAD.BMP  |	00020800   |	434ecfef    |0000066b  |
|MJFIRE.TTM    |	00020e7c   |	4d4aa9d4    |00002c2b  |
|FIRE.BMP      |	00023ab8   |	4649293b    |00001d4c  |
|FIRE3.BMP     |	00025815   |	46490629    |000005bc  |
|FIRE2.BMP     |	00025de2   |	46490834    |000009ea  |
|FIRE5.BMP     |	000267dd   |	46490bad    |00000203  |
|FIRE4.BMP     |	000269f1   |	46490db8    |00002322  |
|FISHING.ADS   |	00028d24   |	4648d496    |00000395  |
|FISHWALK.TTM  |	000290ca   |	4649a4b3    |00000408  |
|MJFISHC.TTM   |	000294e3   |	4d49e8f3    |0000288c  |
|ISLAND2.SCR   |	0002bd80   |	49530df7    |00002333  |
|MJFISH.TTM    |	0002e0c4   |	4d4a8c14    |0000436c  |
|MJFISH1.BMP   |	00032441   |	4d4a40db    |000031f4  |
|MJFISH2.BMP   |	00035646   |	4d4a382e    |0000223d  |
|MJFISH3.BMP   |	00037894   |	4d4a3b7f    |0000169d  |
|LILFISH.BMP   |	00038f42   |	4c48db4e    |00000370  |
|GJCATCH3.BMP  |	000392c3   |	474a7cdb    |00000b8b  |
|GJCATCH1.BMP  |	00039e5f   |	474a7651    |00001cf5  |
|GJCATCH2.TTM  |	0003bb65   |	474a467b    |00000843  |
|GJCATCH2.BMP  |	0003c3b9   |	474a7ffb    |0000554a  |
|SPLASH.BMP    |	00041914   |	535064a2    |00000eee  |
|FISHMAN.BMP   |	00042813   |	4649b913    |00000555  |
|SHKNFIST.BMP  |	00042d79   |	5348ae35    |00000942  |
|GFFFOOD.TTM   |	000436cc   |	4746c5a2    |00000637  |
|GJFFFOOD.BMP  |	00043d14   |	4749f1a0    |0000566c  |
|STAND.ADS     |	00049391   |	5353b044    |000004ae  |
|MJAMBWLK.TTM  |	00049850   |	4d49fe7b    |00002162  |
|MJ\_AMB.BMP   |	0004b9c3   |	4d4a6527    |0000231e  |
|MJTELE.TTM    |	0004dcf2   |	4d4aabc4    |00000ff4  |
|MISCGAG.ADS   |	0004ecf7   |	4d48c85b    |00000108  |
|GJGULL1A.BMP  |	0004ee10   |	474aae39    |00002f52  |
|GJGULL1.TTM   |	00051d73   |	474a3ab3    |0000091d  |
|GJGULL1.BMP   |	000526a1   |	474a6a4b    |00001347  |
|GJANGRY.BMP   |	000539f9   |	474a16cf    |00002f52  |
|GJHOT.TTM     |	0005695c   |	4749ce37    |0000098e  |
|GJHOT.BMP     |	000572fb   |	474aa574    |00002458  |
|SHARK1.TTM    |	00059764   |	534860f1    |00000a5d  |
|SHARKWLK.BMP  |	0005a1d2   |	5348a9b3    |000009ad  |
|SHARK.BMP     |	0005ab90   |	5348ac79    |00004c8f  |
|ACTIVITY.ADS  |	0005f830   |	4142dce8    |000004c4  |
|GJGULL3.BMP   |	0005fd05   |	474a64ff    |00002b78  |
|GJGULL3A.BMP  |	0006288e   |	474aa7e9    |00003640  |
|GJGULL2.BMP   |	00065edf   |	474a619e    |00001b8b  |
|GJGULL2A.BMP  |	00067a7b   |	474aab12    |00000e40  |
|GJNAT1LI.BMP  |	000688cc   |	474a6f8e    |00001e93  |
|MEXCWALK.BMP  |	0006a770   |	4d44c976    |00000f4c  |
|GJDIVE.TTM    |	0006b6cd   |	474a8594    |000010f5  |
|MJDIVE.BMP    |	0006c7d3   |	4d4a6822    |000030e0  |
|GJDIVE.BMP    |	0006f8c4   |	474a550e    |00004daa  |
|MJDIVE.TTM    |	0007467f   |	4d4aa508    |00000c06  |
|MJREAD.TTM    |	00075296   |	4d4a92f8    |000024e5  |
|COCONUTS.BMP  |	0007778c   |	434fd0b2    |00000191  |
|MJREAD.BMP    |	0007792e   |	4d4a5742    |000031af  |
|ZZZZS.BMP     |	0007aaee   |	5a5a8cdd    |0000007b  |
|LITEBULB.BMP  |	0007ab7a   |	4c48f7c2    |0000067b  |
|MJBATH.TTM    |	0007b206   |	4d4aa697    |0000165d  |
|MJBATH.BMP    |	0007c874   |	4d4a6a3d    |00003dfe  |
|JCHANGE.BMP   |	00080683   |	4a42fd77    |00000bcf  |
|GJNAT1.TTM    |	00081263   |	474a3c74    |00001cf9  |
|GJNAT1.BMP    |	00082f6d   |	474a6c8e    |00002b83  |
|BOAT.BMP      |	00085b01   |	424f293b    |00000489  |
|GJNAT3.BMP    |	00085f9b   |	474a6952    |00004325  |
|GJNAT3.TTM    |	0008a2d1   |	474a4410    |00002e6d  |
|VISITOR.ADS   |	0008d14f   |	5648f626    |00000266  |
|MJCOCO.TTM    |	0008d3c6   |	4d4a6e0c    |00001969  |
|GJVIS5.TTM    |	0008ed40   |	474a7701    |000011f7  |
|GJLILIPU.TTM  |	0008ff48   |	474ac116    |00000b84  |
|GJCASTLE.BMP  |	00090add   |	474acba5    |00000c7a  |
|SHIPS.BMP     |	00091768   |	534880cd    |00002ae2  |
|GJVIS6.TTM    |	0009425b   |	474a6f84    |00000fb7  |
|GJVIS6.BMP    |	00095223   |	474a46e6    |0000299c  |
|TANKER.BMP    |	00097bd0   |	54419f0e    |00000aab  |
|GJPROW.BMP    |	0009868c   |	474a7ee6    |00001216  |
|GJVIS5.BMP    |	000998b3   |	474a431b    |00002828  |
|GJVIS3.TTM    |	0009c0ec   |	474a63bd    |00001ed4  |
|ISLETEMP.SCR  |	0009dfd1   |	4952d4ab    |00002c40  |
|MJTELE.BMP    |	000a0c22   |	4d4a79c6    |00001da8  |
|MJTELE2.BMP   |	000a29db   |	4d4a592e    |00000847  |
|GJVIS3.BMP    |	000a3233   |	474a3b8b    |0000150e  |
|TRUNK.BMP     |	000a4752   |	545294d4    |00000a72  |
|FILES.VIN     |	000a51d5   |	46499995    |0000007a  |
|NIGHT.SCR     |	000a5260   |	4e49a943    |000011e0  |
|HOLIDAY.BMP   |	000a6451   |	484ed267    |000009dc  |
|MEANWHIL.TTM  |	000a6e3e   |	4d44fd5c    |00000723  |
|MEANWHIL.BMP  |	000a7572   |	4d45b5a4    |000008c3  |
|SRAFT.BMP     |	000a7e46   |	53528794    |00000397  |
|BUILDING.ADS  |	000a81ee   |	4255b75f    |000006ab  |
|MJSAND.TTM    |	000a88aa   |	4d4aa8d4    |000025aa  |
|SANDCAST.BMP  |	000aae65   |	5341acfc    |00001995  |
|MJSANDC.BMP   |	000ac80b   |	4d49cd77    |00001697  |
|GJRUNAWA.BMP  |	000adeb3   |	474a9099    |0000215c  |
|GJKINGKO.BMP  |	000b0020   |	4749cbe2    |00002e50  |
|GJBIPLAN.BMP  |	000b2e81   |	474a991e    |00001b0a  |
|GJGULIVR.TTM  |	000b499c   |	474a052b    |000040c5  |
|STNDLAY.BMP   |	000b8a72   |	5354c00e    |00001434  |
|SLEEP.BMP     |	000b9eb7   |	534bcac1    |000016b1  |
|LILIPUTS.BMP  |	000bb579   |	4c48e92c    |00001628  |
|FIRE.TTM      |	000bcbb2   |	46496d60    |          |
|FIRE1.BMP     |	000bd078   |	464900ad    |00000b28  |
|MARY.ADS      |	000bdbb1   |	4d415e94    |000002da  |
|SJGLIMPS.TTM  |	000bde9c   |	5349efdb    |000021f4  |
|SMDATE1.BMP   |	000c00a1   |	534d2206    |000013d6  |
|SMGLIMSE.BMP  |	000c1488   |	534ce1f9    |00002170  |
|SASKDATE.TTM  |	000c3609   |	5340f06c    |00001a6c  |
|SMGIFT.BMP    |	000c5086   |	534d9ad7    |00003b41  |
|SJGFTJMP.BMP  |	000c8bd8   |	534ab784    |00000b22  |
|SJGFTSHY.BMP  |	000c970b   |	534a0f5a    |00000edc  |
|SJGFTXCH.BMP  |	000ca5f8   |	534ad18c    |00001dc9  |
|SJGFTASK.BMP  |	000cc3d2   |	534a96b3    |00001655  |
|SMGFTWAV.BMP  |	000cda38   |	534d006e    |00000285  |
|SMDATE.TTM    |	000cdcce   |	534d739d    |00001c55  |
|SMDATE2.BMP   |	000cf934   |	534d1f53    |000012ba  |
|SMDATE3.BMP   |	000d0bff   |	534d1c9e    |00001bb4  |
|SMDATE7.BMP   |	000d27c4   |	534d29c6    |0000056c  |
|SMDATE4.BMP   |	000d2d41   |	534d31df    |000024ce  |
|SMDATE5.BMP   |	000d5220   |	534d2f2e    |000027da  |
|SMDATE6.BMP   |	000d7a0b   |	534d2c7b    |000020ae  |
|SMDATE8.BMP   |	000d9aca   |	534d0ef7    |0000103c  |
|SMDATE9.BMP   |	000dab17   |	534d0c36    |00003944  |
|SMDATE12.BMP  |	000de46c   |	534dc2c2    |00000388  |
|SMDATE10.BMP  |	000de805   |	534cc828    |00001854  |
|SMDATE11.BMP  |	000e006a   |	534ccbd0    |0000187b  |
|SBREAKUP.TTM  |	000e18f6   |	5342be50    |000015d7  |
|MRAFT.BMP     |	000e2ede   |	4d51c878    |00000827  |
|MJRAFT2.BMP   |	000e3716   |	4d4a23fd    |00001672  |
|SJRAFT1.BMP   |	000e4d99   |	534a5eee    |00000d31  |
|SJBRAKUP.BMP  |	000e5adb   |	5349e3e9    |000002ef  |
|SBREAKUP.BMP  |	000e5ddb   |	5341e500    |000040b0  |
|SJLEAVES.TTM  |	000e9e9c   |	5349e553    |00001d18  |
|SLEVEJC1.BMP  |	000ebbc5   |	534c4a31    |0000152f  |
|SLEVEJM1.BMP  |	000ed105   |	534c78c9    |00000bef  |
|SLEVEJC2.BMP  |	000edd05   |	534c5413    |00001262  |
|SLEVEJM2.BMP  |	000eef78   |	534c7583    |00001cca  |
|SLEVEJM3.BMP  |	000f0c53   |	534c723b    |00001031  |
|SLEVEJC3.BMP  |	000f1c95   |	534c50cb    |00001f04  |
|JOHNNY.ADS    |	000f3baa   |	4a4f8e11    |0000026d  |
|THEEND.TTM    |	000f3e28   |	5448926b    |000008d0  |
|THEEND.SCR    |	000f4709   |	54489a7f    |000011d1  |
|THEEND1.BMP   |	000f58eb   |	544842d2    |00000a89  |
|ENDCRDTS.BMP  |	000f6385   |	454eb283    |00000584  |
|SUZY.ADS      |	000f691a   |	53556ab0    |          |
|SUZYCITY.TTM  |	000f6a40   |	5355b1b0    |00001330  |
|SUZBEACH.SCR  |	000f7d81   |	5354ec87    |00001495  |
|SSUZY1.BMP    |	000f9227   |	5353718a    |00001862  |
|SSUZY2.BMP    |	000faa9a   |	53536fb3    |000023b7  |
|SSUZY3.BMP    |	000fce62   |	53536dda    |00004759  |
|WALKSTUF.ADS  |	001015cc   |	57410561    |0000016c  |
|WOULDBE.TTM   |	00101749   |	574fac03    |000034a0  |
|WOULDBE.BMP   |	00104bfa   |	574ee15b    |00003821  |
|JOHNWOUL.BMP  |	0010842c   |	4a4ee325    |000013c7  |
|DRUNKJON.BMP  |	00109804   |	4451f86e    |000024f3  |
|MJRAFT.TTM    |	0010bd08   |	4d4a7977    |0000050a  |
|INTRO.SCR     |	0010c223   |	494e87c7    |000049bf  |
|JOHNCAST.PAL  |	00110bf3   |	4a4ece7d    |00000310  |
|JOHNWALK.BMP  |	00110f14   |	4a4f93ac    |00003bfd  |
|OCEAN00.SCR   |	00114b22   |	4f43a846    |0000146e  |
|OCEAN01.SCR   |	00115fa1   |	4f43ab4d    |0000192b  |
|OCEAN02.SCR   |	001178dd   |	4f43a2de    |0000197f  |
|BACKGRND.BMP  |	0011926d   |	42419e11    |000057aa  |
|CLOUDS.BMP    |	0011ea28   |	434c99d7    |00000624  |

### BMP resource: ###
|Offset|Size (bytes)|Description|
|:-----|:-----------|:----------|
|00000000|4           |Header, always "BMP:"|
|00000004|4           |Width/Height bytes, not used|
|00000008|4           |Header, always "INF:"|
|0000000C|4           |Datasize   |
|00000010|2           |Number of images|
|00000012|images\*2   |Widths of images|
|      |images\*2   |Heights of images|
|      |4           |Header, always "BIN:"|
|      |4           |BMP data size|
|      |1           |Compression method|
|      |4           |Uncompressed size|
|      |Variable    |BMP Data   |
|      |4           |Header, always "VGA:"|
|      |4           |VGA data size|
|      |1           |Compression method|
|      |4           |Uncompressed size|
|      |Variable    |VGA Data (perhaps palette?)|