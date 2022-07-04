#!/usr/bin/env python3 -u

import sys

# global variables

# 00514938 int gRandom_MIDI_tunes[3]  (0x112f38)

# 00514938 = 0     // FILE*
# 0051493c = 0x77  // "w"
# 0051493d = 0x0  // "w null"
# 0051493e = "DIAGNOST.TXT"
#
# 005278D8 scratch [512]


# Overwrite sub_4614F1 with our payload
def patch_sub_4614F1(carm95_binary):
  f = open('dr_dprintf.o.raw', mode = 'rb')
  fc = f.read()
  f.close()
  for i in range(len(fc)):
    carm95_binary[0x608f1 + i] = fc[i]

# Patch dr_dprintf to jump to our new function
def patch_sub_461645(carm95_binary):
  carm95_binary[0x60a45:0x60a4a] = b'\xe9\xa7\xfe\xff\xff'  # jmp sub_4614F1


def patch_global_vars(carm95_binary):
  # Create a NULL FILE*
  carm95_binary[0x112f38:0x112f3c] = b'\x00\x00\x00\x00'

  # Create a "w" string argument for fopen
  carm95_binary[0x112f3c:0x112f3e] = b'\x77\x00'

  # Create a filename argument for fopen
  carm95_binary[0x112f3e:0x112f4a] = str.encode('DIAGNOST.TXT')
  carm95_binary[0x112f4a:0x112f4b] = b'\x00'


def main():
  file_name = sys.argv[1]

  f = open(file_name, mode = 'rb')
  fc = f.read()
  f.close()
  carm95_binary = bytearray(fc)

  if hex(carm95_binary[0x60a45]) != '0x55':  # "push ebp"
    print('ERROR: your carm95 binary does not appear to be valid - first byte of dr_dprintf is', hex(carm95_binary[0x60a45]), ', expected 0x55')
    exit(1)

  patch_global_vars(carm95_binary)
  patch_sub_461645(carm95_binary)
  patch_sub_4614F1(carm95_binary)

  new_path = str.replace(file_name, '.EXE', '.patched.EXE')
  f = open(new_path, mode = 'wb')
  f.write(carm95_binary)
  f.close()
  print('Patched executable written to', new_path)


if __name__ == '__main__':
    sys.exit(main())  # next section explains the use of sys.exit



