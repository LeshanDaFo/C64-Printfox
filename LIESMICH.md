
## PRINTFOX source-code

### PrintFox ist eine von Hans Haberl programmierte Textverarbeitung fuer den C64, welche 1986 von Scanntronik herausgegeben wurde.

Naehere Informationen ueber PrintFox findet man hier:<br />
https://www.c64-wiki.de/wiki/Printfox <br />
<br />

Mit diesem Quellcode ist es moeglich, PrintFox v1.2, bzw. PrintFox in der neuen Version v1.3 zu generieren.<br />

Die zu generierende Version kann im Quellcode eingestellt werden.<br />

#### Was ist neu in PrintFox v1.3?

Mit der Version 1.3 ist es nun moeglich, Printfox von jedem Laufwerk aus zu starten.<br />
Um diese Funktion zu nutzen, muss die Disc "Printfox V1.3" aus diesem Repository genutz werden.<br />

Die Start-Laufwerksnummer wird vom C64 in der Standardadresse $BA gespeichert.<br />
Die dort eingetragene Laufwerksnummer wird im Printfox am Ende der ersten Statuszeile angezeigt.<br />
<br />
Im Printfox selber ist es nun moeglich, ein Laufwerk zum Laden oder Speichern auszuwaehlen.<br />
<br />
Im Printfox wird bei den Befehlen zum Laden, Speichern oder Drucken nun vorher das Laufwerk abgefragt, und kann dort entsprechend geaendert werden.<br />
Es erscheint dann die Meldung "LW NR.:" gefolgt von der aktuellen Lufwerksnummer.
Hier kann man entweder durch Druecken von RETURN das aktuelle Laufwerk bestaetigen, oder die angezeigte Laufwerksnummer ueberschreiben, und anschliessend mit RETURN bestaetigen.

Moegliche Laufwerksnummern sind 8 - 19.<br />
Die Zahl muss ohne fuehrende Leerzeichen eingegeben werden. Es wird zunaechst die erste Zahl ueberprueft, ist es eine 8 oder 9, so wird die nechste Zahl uebersprungen, und nicht weiter ueberprueft.<br />
Wird als erste Zahl eine 1 erkannt, so wird auch die zweite Zahl ueberprueft.<br />

Die so erkannte Laufwerksnummer wird uebernommen, und am Ende der ersten Statuszeile angezeigt.<br />

Ist ein so gewaehltes Laufwerk nicht angeschlossen, wird die Eingabe ignoriert, und mit dem Laden, bzw. Speichern mit der bestehenden Laufwerksnummer fortgefahren.<br />

Ebenso wird eine ungueltige Eingabe ignoriert.<br />
<br />
Bitte auch die Beschreibung im Source-Code beachten.<br />
<br />
<br />

#### PrintFox 1.3 Screenshot<br />
![Screenshot 2023-11-14 at 14 20 52](https://github.com/LeshanDaFo/C64-PrintFox1.3/assets/97148663/dd739319-1a02-426c-a646-98122b89cc5f)

<br />
<br />
<br />
<br />
<br />

### ANMERKUNG:

verwendete Software:
Visual Studio Code, Version: 1.83.1
Acme Cross-Assembler fuer VS Code (C64) v0.0.18

verwendete Hardware:
Apple iMac (24-inch, M1, 2021)

Der Source-Code kann mit dem Acme Cross Compiler (C64) kompiliert werden.

Gebrauch des Source-Codes auf eigene Gefahr ;)
