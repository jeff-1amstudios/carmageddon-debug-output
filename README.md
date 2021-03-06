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

In the retail executable, none of the code inside the `#ifdef` is included, so nothing is logged. However, this function is still being called with all sorts of interesting messages, so it would be nice to re-enable it!

## How it works

### Executable patches

We make three patches in `CARM95.EXE`.

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


## Patch your CARM95.EXE:

Grab `patch.py` from this repo, then run the following command. It will create a `CARM95.patched.EXE` file.

```bash
./patch.py c:\path\to\CARM95.EXE
```

When `CARM95.patched.EXE` is run, it will log debug messages into `DIAGNOST.TXT` in the same directory.

Example output:
```
...
Start of LoadInOppoPaths()...
ReallocExtraPathNodes(): Allocated 4544 bytes for 71 path nodes
ReallocExtraPathSections(): Allocated 4000 bytes for 100 path sections
End of LoadInOppoPaths(), totals:
Nodes: 71
Sections: 100
Car 'Screwie Lewie', car_ID 200
Car 'Stig O'Sore', car_ID 201
Car 'Auto scum', car_ID 202
Car 'Kutter', car_ID 203
Car 'Ed 101', car_ID 204
StartRecordingTrail - starting from scratch
Screwie Lewie: Choosing new objective because we have to...
Screwie Lewie: NewObjective() - type 1
Screwie Lewie: ProcessCompleteRace() - new objective started
...
```


## Making changes to the replacement code
If you make a change to `dr_dprintf.s`, it needs to be re-assembled into raw x86 code and updated in `patch.py`.

```bash
# compile assembly into x86 binary code
cc -c -masm=intel -m32 dr_dprintf.s
objcopy  --dump-section .text=dr_dprintf.o.raw dr_dprintf.o

# update 'payload_base64' in patch.py
sed -i "" "s#payload_base64.*#payload_base64=\'$(base64 dr_dprintf.o.raw)\'#" patch.py
```

