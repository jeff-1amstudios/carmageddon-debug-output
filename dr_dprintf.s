



# functions defined in carma95 executable
fputs = 0x004EC550
fopen = 0x004EBF40
fputc = 0x004EE5E0
vsprintf = 0x004EFD40
fflush = 0x004F1FE0

# variable locations in carma95 executable
gRandom_MIDI_tunes = 0x00514938
str_w = 0x0051493c
str_diag = 0x0051493e
scratch = 0x005278D8


push  ebp
mov   ebp, esp
push  ebx
push  esi
push  edi
mov   eax, [gRandom_MIDI_tunes]
test  eax, eax
jne    file_already_open

push  str_w   # "w"
push  str_diag   # "DIAG.TXT"
mov   edx, fopen
call  edx
add   esp, 8
mov   [gRandom_MIDI_tunes], eax       # gRandom_MIDI_tunes

file_already_open:

lea eax, [ebp+12]  # first vararg
push eax
push  [ebp+8]     # fmt
push  scratch
mov   edx, vsprintf
call  edx
add   esp, 0xc

push  [gRandom_MIDI_tunes]              # gRandom_MIDI_tunes
push  scratch
mov   edx, fputs
call  edx
add   esp, 8

push  [gRandom_MIDI_tunes]   # gRandom_MIDI_tunes
push  0x0A             # int
mov   edx, fputc
call  edx
add   esp, 8

push  [gRandom_MIDI_tunes]   # gRandom_MIDI_tunes
mov   edx, fflush
call  edx
add   esp, 4

pop   edi
pop   esi
pop   ebx

leave
ret
