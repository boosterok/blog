start = 0x1e8cf8
def u32(a, i):
	i -= 0x180000
	return a[i] | (a[i+1]<<8) | (a[i+2]<<16) | (a[i+3]<<24)

with open("bcm_rambytes.bin", "rb") as infile:
	indata = infile.read()

curr = start
#curr = u32(indata, curr + 4)
end = 0
while True:
	size = u32(indata, curr)
	next = u32(indata, curr + 4)
	print(hex(curr), hex(size), hex(next))
	if end != 0 and curr < end:
		for i in range(0, size, 4):
			dat = u32(indata, curr + 8 + i)
			print(hex(dat))
			if dat > 0x180000 and dat < 0x1dc3c4:
				exit(0)
	if indata[curr + 8 - 0x180000:curr + 8 + 5 - 0x180000] == b"\x00\x50\xf2\x02\x01":
		print("Found one")
		end = curr + 8 + 0xff
	#if next == 0:
	#	break
	#curr = next
	if size == 0x5354414b:
		break
	curr = curr + 8 + size
