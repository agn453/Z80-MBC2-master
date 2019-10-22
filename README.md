# Z80-MBC2-master
Custom CP/M 3 BIOS for Z80-MBC2 single board computer

This repository contains the original CP/M 3 BIOS source files, plus
my modified files to support either the original DR supplied CP/M 3
BDOS modules, or Simeon Cran's ZPM3 replacement BDOS modules for the
Z80-MBC2 single board computer
( see https://hackaday.io/project/159973-z80-mbc2-4ics-homemade-z80-computer )

The original BIOS modules (from the Hackaday SD-S220718-R280819-v1.zip file)
have been translated from 8080 Assembly language compatible with the DR RMAC
assembler into Zilog Z80 mnemonics that can be assembled using the
Microsoft M80 Macro Assembler or (my preferred) Hector Peraza's ZSM4 Macro
Assembler.

The source-code for ZSM4 may be obtained from https://github.com/hperaza/ZSM4
and I have included a working CP/M binary for ZSM4 version 4.1

Modification History (in reverse chronological order):
======================================================

22-Oct-2019
-----------

Firstly, I have attempted to re-construct the distributed CP/M 3 system
image file (CPM3-128.SYS) - so far unsuccessfully (I'm waiting on details
concerning the original build procedure and GENCPM configuration file).

The build procedure submit file BUILD.SUB does a long-winded build of the
original Intel 8080 sourcecode modules (.ASM files) and my translated
sourcecode modules (.Z80 files).  Both the original and translated build
files produce byte-identical BIOS images.  As soon as I have the original
build files, I can substitute my attempt at reconstruction in the
GENCPM.ORG file (this is the data file input to the CP/M 3 system generation
program GENCPM.COM).

Secondly, I have modified the Z80 sourcecode modules to -

* Incorporate some byte-saving optimizations (replace absolute jumps with
relative ones) in the BIOSKRNL module.

* Moved the sign-on message text into banked memory (it is only used on
start-up) in the BOOT module.

* Fixed the ?TIME routine to transfer all 7 bytes of data from the IO
processor (ATmega32A).  Although there's no routine to return it, the
temperature reading in degrees Celsius is now exposed via a global
variable @TEMPC.

* Removed unused common stack space from the CHARIO module.

* Added XMOVE capability to the MOVE module.  This allows programs
like BOOTSYS to load a replacement system image into the correct
memory banks for testing.

* Added a zero checksum vector size to invokations of the DPH macro
since all drives are permanently mmounted - in the VDISK module.

My modified Z80 sourcecode is in various .MAC modules and can be built
into a system image by the BUILDZPR.SUB (which selects the ZPM3
replacement BDOS routines).

ZPM3 sourcecode can be obtained from the Tesseract RCPM+ archives in Volume
93 at http://www.classiccmp.org/cpmarchives/cpm/mirrors/www.triton.vg/TesseractRCPM+Catalog.html#vol93

The resulting system gives a 61KB TPA

```
Z80-MBC2 - A040618                                                              
IOS - I/O Subsystem - S220718-R280819                                           
                                                                                
IOS: Found extended serial Rx buffer                                            
IOS: Z80 clock set at 10MHz                                                     
IOS: Found RTC DS3231 Module (22/10/19 13:38:59)                                
IOS: RTC DS3231 temperature sensor: 25C                                         
IOS: Found GPE Option                                                           
IOS: CP/M Autoexec is OFF                                                       
IOS: Current Disk Set 2 (CP/M 3.0)                                              
IOS: Loading boot program (CPMLDR.COM)... Done                                  
IOS: Z80 is running from now                                                    
                                                                                
                                                                                
                                                                                
Z80-MBC2 CPMLDR BIOS - S180918                                                  
                                                                                
CPMLDR3 - CP/M V3.0 Loader                                                      
Copyright (C) 1982, Digital Research                                            
                                                                                
 RESBIOS3 SPR  FA00  0600                                                       
 BNKBIOS3 SPR  5600  2A00                                                       
 RESBDOS3 SPR  F400  0600                                                       
 BNKBDOS3 SPR  2800  2E00                                                       
                                                                                
 61K TPA                                                                        
                                                                                
Z80-MBC2 128KB (Banked) CP/M V3.0 with ZPM3                                     
Z80-MBC2 BIOS Modules: S200918, S210918-R170319, S220918-R180319, S290918,      
 S170319                                                                        
                                                                                
                                                                                
A>setdef * a: [order=(com,sub) display uk] 
```

If you don't wish to rebuild everything from sourcecode, the file ZPM3.SYS
can be copied to CPM3.SYS prior to rebooting with a RESET.

ZPM3 has a built-in command editor that uses WordStar compatible keystrokes.
CTRL-X and CTRL-E advance and goback each command, and CTRL-Y is used to
remove a command line.  Full documentation is on the Tesseract Volume 93.

If you wish to download all modules in a single convenient file then
fetch the
https://github.com/agn453/Z80-MBC2-master/blob/master/MBC2BIOS.LBR library
and extract the contents to an empty directory using the CP/M NULU.COM utility
and ```lu d:MBC2BIOS.LBR -e *.*```

All the files (and assembly listings) are in the bios directory.

