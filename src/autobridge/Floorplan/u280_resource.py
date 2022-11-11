from collections import defaultdict
resources = defaultdict(lambda: defaultdict(dict))

resources[1][0] = {
  "BRAM" : 432,
  "DSP"  : 1296,
  "FF"   : 361920,
  "LUT"  : 180960,
  "URAM" :192,
}

# Slot CR_X0Y0_To_CR_X3Y3:
resources[0][0] = {
  "BRAM" :  768,
  "DSP"  :  1440,
  "FF"   :  441600,
  "LUT"  :  220800,
  "URAM" : 128,
}

# Slot CR_X0Y4_To_CR_X3Y7:
resources[0][1] = {
  "BRAM" :  768,
  "DSP"  :  1536,
  "FF"   :  433920,
  "LUT"  :  216960,
  "URAM" : 128,
}

# Slot CR_X4Y4_To_CR_X7Y7:
resources[1][1] = {
  "BRAM" :  384,
  "DSP"  :  1344,
  "FF"   :  330240,
  "LUT"  :  165120,
  "URAM" : 192,
}

# Slot CR_X0Y8_To_CR_X3Y11:
resources[0][2] = {
  "BRAM" :  768,
  "DSP"  :  1536,
  "FF"   :  433920,
  "LUT"  :  216960,
  "URAM" : 128,
}

# Slot CR_X4Y8_To_CR_X7Y11:
resources[1][2] = {
  "BRAM" :  384,
  "DSP"  :  1344,
  "FF"   :  330240,
  "LUT"  :  165120,
  "URAM" : 192,
}
