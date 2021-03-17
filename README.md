# Z80-MBC2-master
## Custom CP/M 3 BIOS and Sketches for Z80-MBC2 single board computer

This repository contains the original CP/M 3 BIOS source files, plus
my modified files to support either the original Digital Research Inc.
supplied CP/M 3 BDOS modules, or Simeon Cran's ZPM3(1) replacement BDOS
modules for the Z80-MBC2 single board computer
(see https://hackaday.io/project/159973-z80-mbc2-4ics-homemade-z80-computer
for details)

The original BIOS modules (extracted from the Hackaday microSD
SD-S220718-R280819-v1.zip file)
have been translated from the original RMAC-style 8080 Assembly language
format into Zilog Z80 mnemonics and can be assembled using the
Microsoft M80 Macro Assembler or (my preferred) Hector Peraza's ZSM4 Macro
Assembler(2).

## Modification History (in reverse chronological order):

### 17-Mar-2021

Modify the XMODEM program to use half the available memory for buffering
the file to send or receive.  The relatively slow access time to read or
write a file to the microSD card was causing a time-out and abort when
sending or receiving large files while the file was being read/written.


### 16-Mar-2021

Some minor updates to allow debugging the banked BIOS memory move
module (XMOVE and MOVE).  Two additional submit files are included
to build banked system images (DRI3DBG.SYS and ZPM3DBG.SYS) that can
trace the calls to the BIOS XMOVE and MOVE routines by outputting
messages to the console.  I used these to track down an issue with
the Digital Research banked BIOS that may cause memory corruptions.
The issue doesn't seem to occur if you use the ZPM3 banked BDOS
replacement (from ZPM3.SYS).


### 26-Jun-2020

Include latest Arduino sketches for the Z80-MBC2 board.

* Z80-MBC2-ATmega32A-PU is a copy of the unmodified release
S220718-R240620_IOS using the ATmega32A-PU chip.  This includes
support for CollapseOS.

* Z80-MBC2-ATmega1284P-PU contains my modifications for the ATmega1284A-PU
chip.  This was forked from https://github.com/HomebrewMicros/Z80-MBC2-ATMEL1284
and also contains the CollapseOS updates too.

To build the sketches under the Arduino IDE with XMODEM extended buffering
support, you must modify the MightyCore board definitions to include extra
symbol definitions for SERIAL_RX_BUFFER_SIZE=256 and SERIAL_TX_BUFFER_SIZE=64.
The file arduino-changes-MightyCore-2.0.5.readme has a context diff for
the version I'm using.

Also, I've updated ZSM4.COM to the latest release.


### 17-Feb-2020

Tidy up the build files.  BUILDDRI.SUB now builds a DRI3.SYS file from
the Digital Research supplied Resident BDOS modules, and BUILDZPR.SUB
produces ZPM3.SYS from Simeon Cran's ZPM3 replacement BDOS modules.

Also included the source-code to the Z80-MBC2 version of XMODEM and
AUTOEXEC.ASM (from the SD card src/CPM_3_Utils folder) and cleaned
up stray NUL and CTRL-Z characters from the end of text files.


### 22-Oct-2019

Firstly, I have attempted to re-construct the distributed CP/M 3 system
image file (CPM3-128.SYS).

The build procedure submit file BUILD.SUB does a long-winded build of the
original Intel 8080 sourcecode modules (.ASM files) and my translated
sourcecode modules (.Z80 files).  Both the original and translated build
files produce byte-identical BIOS images.  However, even using the
original GENCPM.ORG configuration, I'm unable to get a byte-for-byte
exact copy of the distributed banked system CPM3-128.SYS. Most likely
this is due to differences in un-initialized data areas.

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

* Added a zero checksum vector size to invocations of the DPH macro
since all drives are permanently mounted - in the VDISK module.

My modified Z80 sourcecode is in various .MAC modules and can be built
into a system image by the BUILDZPR.SUB submit file (which selects the ZPM3
replacement BDOS routines).

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
can be copied to CPM3.SYS on the A: drive prior to rebooting with a RESET.

ZPM3 has a built-in command editor that uses WordStar compatible keystrokes.
CTRL-X and CTRL-E advance and goback each command, and CTRL-Y is used to
remove a command line.  CTRL-S and CTRL-D are cursor left and right and
CTRL-G is delete current character.  Full documentation is on the
Tesseract Volume 93.

If you wish to download all modules in a single convenient file then
fetch the
https://github.com/agn453/Z80-MBC2-master/blob/master/MBC2BIOS.LBR library
and extract the contents to an empty directory using the CP/M NULU.COM utility
with a command like ```nulu d:MBC2BIOS.LBR -e *.*``` from the CP/M prompt.

All the files (and assembly listings) are in the bios directory.

--

(1) ZPM3 sourcecode can be obtained from the Tesseract RCPM+ archives
in Volume 93 at
http://www.classiccmp.org/cpmarchives/cpm/mirrors/www.triton.vg/TesseractRCPM+Catalog.html#vol93

(2) The source-code for ZSM4 Z80/Z180/Z280 Macro Assembler may be obtained from
https://github.com/hperaza/ZSM4
and I have included a working CP/M binary for ZSM4 version 4.1 (ZSM4.COM)
and the PDF documentation (ZSM4.PDF)


