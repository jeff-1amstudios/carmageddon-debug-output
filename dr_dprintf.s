# Re-enables basic debug output in the retail Carmageddon windows95 binary by patching the empty dr_dprintf function.
# jeff@1amstudios.com

###############################################################################
# Virtual address of useful functions in carma95 executable
###############################################################################
fputs = 0x004EC550
fopen = 0x004EBF40
fputc = 0x004EE5E0
vsprintf = 0x004EFD40
fflush = 0x004F1FE0


###############################################################################
# Virtual address of variables in carm95 executable.
# Overwrites unused 'int gRandom_MIDI_tunes[3]' variable
###############################################################################
var_filepointer = 0x00514938
var_w = 0x0051493c
var_filename = 0x0051493e
var_scratch_buffer = 0x005278D8


###############################################################################
# Shell code function starts here
###############################################################################
push  ebp
mov   ebp, esp
push  ebx
push  esi
push  edi

# Have we opened the file already?
mov   eax, [var_filepointer]
test  eax, eax
jne    file_already_open

# Open DIAGNOST.TXT file for writing
push  var_w
push  var_filename
mov   edx, fopen
call  edx                     # fopen("DIAGNOST.TXT", "w")
add   esp, 8
mov   [var_filepointer], eax  # store FILE* result in var_filepointer

file_already_open:


# Process format string and arguments into final string
lea eax, [ebp+12]
push eax                      # address of first var arg
push  [ebp+8]                 # fmt arg
push  var_scratch_buffer      # where to write string to

mov   edx, vsprintf
call  edx                     # vsprintf(fmt, args)
add   esp, 0xc

# Write output string to file
push  [var_filepointer]
push  var_scratch_buffer
mov   edx, fputs
call  edx                     # fputs(file, msg)
add   esp, 8

# Append newline
push  [var_filepointer]
push  0x0A
mov   edx, fputc
call  edx                     # fputc('\n')
add   esp, 8

push  [var_filepointer]
mov   edx, fflush
call  edx                     # fflush(file)
add   esp, 4

pop   edi
pop   esi
pop   ebx

leave
ret
