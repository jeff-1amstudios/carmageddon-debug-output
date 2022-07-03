# Re-enabling Carmageddon debug output

```bash
cc -c -masm=intel -m32 dr_dprintf.s
```

```bash
objdump -D -x86-asm-syntax=intel dr_dprintf.o
```

```bash
objcopy  --dump-section .text=dr_dprintf.o.raw dr_dprintf.o
```

```bash
./patch.py /path/to/CARM95.EXE
```

