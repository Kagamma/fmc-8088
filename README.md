# fmc-8088

A modification of Faust Music Creator, allows it to be used on IBM PC compatible computers.

Based on the source code at https://www.vogons.org/viewtopic.php?t=62121, here are the changes that I made:
- Display text cursor properly on CGA card, enabling the use of the program as an Adlib OPL2 tracker on 8088 machine.
- For the Book 8088, which does not have a keypad, you can use Shift+0-6 to change the octave.
- Disable switching display mode at the start of program to avoid screen issues on the Book 8088, so make sure you are already in mode 80 before running the program.

The binary is included in the repo.

![FMC on Book 8088](/image.jpg)
