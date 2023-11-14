
## PRINTFOX source-code

### Printfox is a word processor software programmed by Hans Haberl for the C64, which was published by Scanntronik in 1986.

Information about PrintFox can be found here:<br />
https://www.c64-wiki.de/wiki/Printfox<br />
<br />
With this source code it is possible to generate PrintFox v1.2 or PrintFox as the new v1.3 as an executable program.<br />

The version to be generated can be set in the source code.<br />
<br />

#### What's new in PrintFox v1.3<br />

With version 1.3 it is now possible to load and start Printfox from any drive.<br />
This needs the disc 'Printfox V1.3', with adjusted loader files.<br />
This disc is available in this repository.<br />

The boot drive number is stored by the C64 in the standard address $BA.
This drive number entered there is displayed in Printfox at the end of the first status line.<br />
<br />
In Printfox itself it is now possible to select a drive for loading or saving.<br />
<br />
In Printfox, the drive is now queried beforehand for the commands to load, save or print and can be changed there accordingly.<br />
The message “LW NO.:” will then appear followed by the current drive number.
Here you can either confirm the current drive by pressing RETURN, or overwrite the displayed drive number and then confirm with RETURN.

Possible drive numbers are from 8 to 19.<br />
The number must be entered without leading spaces. First the first number is checked; if it is an 8 or 9, the next number is skipped and no further check is carried out.<br />
If a 1 is recognized as the first number, the second number is also checked.<br />

The drive number recognized in this way is used now for load or save, and will be displayed at the end of the first status line.<br />

If a drive selected in this way is not connected, the input will be ignored and loading or saving will continue with the existing drive number.<br />

Also, an invalid entry is ignored.<br />
<br />
Please read also the information in the source code header.<br />
<br />
<br />


#### PrintFox 1.3 Screenshot<br />

![Screenshot 2023-11-14 at 14 20 52](https://github.com/LeshanDaFo/C64-PrintFox1.3/assets/97148663/dd739319-1a02-426c-a646-98122b89cc5f)

<br />
<br />
<br />
<br />
<br />

### REMARK:

Used Software:
Visual Studio Code, Version: 1.83.1
Acme Cross-Assembler for VS Code (C64) v0.0.18

Used Hardware:
Apple iMac (24-inch, M1, 2021)

The source code can be compiled by using the Acme Cross Compiler (C64)

Please use this source code on your own risk ;)
