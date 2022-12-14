/* SPDX-License-Identifier: GPL-2.0-only */
/*
 * Copyright (C) 2012 ARM Ltd.
 */

#include <linux/linkage.h>
#include <linux/const.h>
#include <asm/assembler.h>
#include <asm/page.h>
#include <asm/cpufeature.h>
#include <asm/alternative.h>

/*
 * Copy a page from src to dest (both are page aligned)
 *
 * Parameters:
 *	x0 - dest
 *	x1 - src
 */
SYM_FUNC_START_PI(copy_page)
alternative_if ARM64_HAS_NO_HW_PREFETCH
	// Prefetch three cache lines ahead.
	prfm	pldl1strm, [x1, #128]
	prfm	pldl1strm, [x1, #256]
	prfm	pldl1strm, [x1, #384]
alternative_else_nop_endif

	ldp	x2, x3, [x1]
	ldp	x4, x5, [x1, #16]
	ldp	x6, x7, [x1, #32]
	ldp	x8, x9, [x1, #48]
	ldp	x10, x11, [x1, #64]
	ldp	x12, x13, [x1, #80]
	ldp	x14, x15, [x1, #96]
	ldp	x16, x17, [x1, #112]

	add	x0, x0, #256
	add	x1, x1, #128
1:
	tst	x0, #(PAGE_SIZE - 1)

alternative_if ARM64_HAS_NO_HW_PREFETCH
	prfm	pldl1strm, [x1, #384]
alternative_else_nop_endif

	stnp	x2, x3, [x0, #-256]
	ldp	x2, x3, [x1]
	stnp	x4, x5, [x0, #-240]
	ldp	x4, x5, [x1, #16]
	stnp	x6, x7, [x0, #-224]
	ldp	x6, x7, [x1, #32]
	stnp	x8, x9, [x0, #-208]
	ldp	x8, x9, [x1, #48]
	stnp	x10, x11, [x0, #-192]
	ldp	x10, x11, [x1, #64]
	stnp	x12, x13, [x0, #-176]
	ldp	x12, x13, [x1, #80]
	stnp	x14, x15, [x0, #-160]
	ldp	x14, x15, [x1, #96]
	stnp	x16, x17, [x0, #-144]
	ldp	x16, x17, [x1, #112]

	add	x0, x0, #128
	add	x1, x1, #128

	b.ne	1b

	stnp	x2, x3, [x0, #-256]
	stnp	x4, x5, [x0, #-240]
	stnp	x6, x7, [x0, #-224]
	stnp	x8, x9, [x0, #-208]
	stnp	x10, x11, [x0, #-192]
	stnp	x12, x13, [x0, #-176]
	stnp	x14, x15, [x0, #-160]
	stnp	x16, x17, [x0, #-144]

	ret
SYM_FUNC_END_PI(copy_page)
EXPORT_SYMBOL(copy_page)
