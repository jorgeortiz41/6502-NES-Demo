## Demo.asm

The `demo.asm` file is an assembly language program for the NES (Nintendo Entertainment System). It contains code that demonstrates various features and capabilities of the NES hardware.

To run the program, follow these steps(these are the ones i used on my mac):

1. Install `ca65` assembler via Homebrew by running the following command in your terminal:

   ```shell
   brew install cc65
   ```

2. Install an NES emulator of your choice. There are several options available, such as FCEUX, Nestopia, or Mesen.

3. Navigate to the directory where the `demo.asm` file is located.

4. Assemble the `demo.asm` file using the `ca65` assembler by running the following command in your terminal:

   ```shell
   ca65 demo.asm
   ```

5. Link the assembled object file (`demo.o`) to create an NES ROM file (`demo.nes`) by running the following command:

   ```shell
   ld65 demo.o -t nes -o demo.nes
   ```

6. Open the generated `demo.nes` file in your NES emulator to see the program in action.

Please note that the exact commands and steps may vary depending on your operating system and setup.
