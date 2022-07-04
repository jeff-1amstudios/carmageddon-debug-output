# Re-enabling Carmageddon debug output

Carmageddon shipped with a commented-out debug output function that probably looked something like

```c
void dr_dprintf(char *message, args...) {
#ifdef DEBUG_ENABLED
  ...
  fprintf(output_file, message, args);
  ...
#endif
}
```

In the retail executable, `DEBUG_ENABLED` is not defined so we don't get any debug output. However, this function is still being called with all sorts of interesting messages, so it would be nice to re-enable it!

## How it works

### Executable patches

We make three patches in the carm95 executable:

1) Overwrite unused global variables related to MIDI playback (`gRandom_MIDI_tunes`, `gRandom_Rockin_MIDI_tunes`) to give us a place to store the output filename and file pointer.
2) Insert a `JMP` instruction into the original `dprintf` debug output function to call our shellcode
3) Overwrite an unused function (`sub_4614F1`) with our replacement code (`dr_dprintf.s`)

### Replacement code

The code contained in `dr_dprintf.s` does the following:

1) Open `DIAGNOST.TXT` for writing, store the `FILE*` into an unused MIDI global variable
2) Call `vsprintf`, passing the original format string and args
3) Call `fputs` to write the resulting string to the file
4) Call `fputc` to write a newline
5) Call `fflush` to flush the new line to disk
6) Returns back to the caller of the original `dr_dprintf` function


## Patch your carm95 executable:

Running the following command creates a `CARM95.patched.EXE` file in the same directory.

```bash
./patch.py c:\path\to\CARM95.EXE
```



## Making changes to the shellcode payload
If you make a change to `dr_dprintf.s`, it needs to be re-assembled into `dr_dprintf.o.raw`. This file is expected to only contain raw 32-bit x86 code.

```bash
cc -c -masm=intel -m32 dr_dprintf.s
objcopy  --dump-section .text=dr_dprintf.o.raw dr_dprintf.o
```

