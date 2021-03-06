Blobless Linux on the Pi
==================
_13 Feb 2017_

Over winter break, I successfully modified Kristina Brook's free Raspberry Pi
[firmware](https://github.com/christinaa/rpi-open-firmware), a low-level
program for hardware initialisation, which with my contributions is able to
bring-up and boot a Linux kernel. Most of the bits and pieces were already
there from when the firmware was actively developed in June of 2016; that being
said, it was purely a proof-of-concept showing ARM initialisation -- no
payloads were actually loaded, let alone Linux. In this post, we'll walk
through the steps of writing the necessary bootloader (and all the pitfalls to
which we were victims.)

First things first, what exactly is it that we're trying to accomplish? Well,
we need to know a bit about how computers boot. Essentially it's a chain of
programs, each larger than the last whose job is to load the next one. Over
years of legacy code piling up, it is admittedly rather convoluted, especially
on x86. But the theory is the same: the bootrom (burned into the chip) loads
the firmware, the firmware loads the bootloader, the bootloader loads the
kernel, the kernel loads the userspace. The exact contents of each step vary
wildly -- and before you ask, yes, this is the reason your computer takes so
long to load in the morning :-)

The Raspberry Pi is somewhat... special in this regard. Usually, for systems
with a graphics processor (like my Intel-based laptop), the CPU boots up and
later triggers bring-up of the GPU. For various (strange) historical reasons,
the Raspberry Pi instead boots from the VideoCore 4 GPU, which loads the CPU
at-will. Another caveat is that the firmware is not actually on a ROM like you
would expect -- it's on an SD card, or potentially even stranger mediums.
Finally, while third-party bootloaders like U-Boot exist for the Pi, the stock
firmware is setup to boot Linux directly. So, the boot chain for the official
firmware is something like: bootrom (VC4) loads the GPU operating system, the
GPU loads the kernel into memory, the GPU loads ARM with a stub program, the
ARM stub jumps to Linux, and Linux loads user-space. It's pretty crazy.

Some of these, er, peculiarities are due to fundamental differences in the
system-on-chip used in the Raspberry Pi. Much of it was simply design of the
firmware. Kristina's firmware used a slightly different path, from which we'll
work: the bootrom loads her minimal GPU program, the GPU brings up ARM with an
embedded ARM program, the ARM program initialises a handful of additional
peripherals and then hangs. What peripherals, you may ask? Well, most notably
she was kind enough to include an eMMC driver (for SD cards) and she bundled a
library for reading FAT filesystems. That is, the infrastructure is setup to
read files from the SD card.

The (simplest) path from here is clear. Rather than hang at the end of ARM
program, load the kernel from the SD card and chuck it somewhere into memory.
Then, in theory, you should be able to jump to it on ARM, and let Torvalds'
crowd do the rest. It's easy... right?

Unfortunately, Linux is rather... demanding, hence why bootloaders are used at
all. If you're curious at the exact details on ARM -- which are comparatively
trivial next to certain other architectures, ahem -- see the [official
documentation](https://github.com/anholt/linux/blob/rpi-4.4.y/Documentation/arm/Booting).
See, before we can just jump to the kernel image in memory, it's necessary to
pass a variety of arguments to it. There are the easy ones, like setting a few
registers to magic values, but something stands out as particularly irritating:
the legacy "tagged list" or the more modern device tree. To understand the
purpose -- and associated nightmares -- of these, it's necessary to take
another detour into the typical boot process.

Essentially, the kernel has two jobs: managing resources for users via
scheduling, permission systems, and the like (interesting to other people), and
managing the hardware (interesting to us). The former category is easy, and
it's fairly similar across architectures -- when people say a kernel is "a UNIX
system", they are generally referring to this component. The latter, however,
is necessarily different for each and every hardware configuration. Actually
implementing these drivers is a nightmare we'll approach later; for now, it's
just necessary to know it's there, and to ask the inevitable question:
precisely *what* hardware does the kernel manage?

It turns out there are a few obvious ways of handling this. The kernel could
guess (bad idea). It could hard code what hardware is available (simple but
unmaintainable). It could probe the system at run-time (sounds nice but is
inevitably difficult in practice). Certain architectures, of course, favour
certain methods. x86, for one, favours probing, encouraged by (highly
criticized) systems like ACPI, EFI, and the BIOS. On the other hand, ARM, used
in the Raspberry Pi and focused on embedded systems, assumes the kernel
automagically knows what hardware to use, by hard-coding I suppose. Linux on
ARM takes a middle ground: it uses a configurable device tree that contains a
variety of information about the hardware, loaded at runtime. Normally I'd
write this off as something for the geeks on the mailing list to sort out, but
apparently information "loaded at runtime" is our responsibility now.

In a (rare) stroke of luck, the device tree files are the same with the stock
firmware... mostly. We can get much of what we need from the official
[trees](https://github.com/raspberrypi/firmware/blob/master/boot/bcm2709-rpi-2-b.dtb),
anyways. It's tempting to throw that on the SD card along with the kernel, load
that into memory along with the kernel, and *now* jump. Oh, and pass the
address of the blob in a register before jumping, as per the Linux
specification. Surely we're done, right?

Nope! See, the device tree blob does quite a bit more than simply enumerating
peripherals. One field that the bootloader (that is, our code) needs to fill is
the kernel arguments. For those of you who aren't familiar with Linux, the
kernel accepts a handful of parameters, much like a userspace program,
controlling all sorts of behaviours; importantly, they determine the root
device, which will matter later. So, the strategy is, like the stock firmware,
throw the command-line options into a file on the SD card, load *them* into
memory, and pass it -- err, how do we pass this exactly? I did say it was in
the device tree. Yes, we need to modify the device tree at run-time^[I am aware
there are other ways to approach this in a super minimalist setup, although
this is the approach used in the stock firmware and is therefore how users will
expect it to work.]. Pull in
[libfdt](https://github.com/dgibson/dtc/tree/master/libfdt), and patch in the
correct field (`chosen/bootargs`), and that's that. Additionally, a memory map
needs to be specified under the `/memory` node, which can be patched in the
same
[way](https://github.com/christinaa/rpi-open-firmware/blob/master/arm_chainloader/loader.cc#L74).
Onwards!

If we had a dynamic initramfs we wanted to load, that would be yet a third blob
to load from the SD card and chuck at the kernel, though to keep everything
simple, we can skip this (for now). Indeed, at this point everything is place
for the boot. According to the specification, we need to set a few registers to
    magic values and the device tree address, and jump to the kernel. Wait a
    minute, registers? This is C code! Ugh, I guess we'll need to drop down
    into assembly for the final jump...

Alternatively, we can appreciate the Linux's choice of registers, `r0` through
`r2`. Depending on your familiarity with low-level ARM code, you might
recognize these registers as storage for the first three arguments in the
standard ARM calling convention. That is, with the right type specification,
you can cast the kernel blob in memory to a function, and just "call" it! The
first two arguments are magic numbers, zero and all ones, and the third
argument is the DTB pointer, so we define it like so:

    typedef void (*linux_t)(uint32_t, uint32_t, void*);

Later, we cast the kernel blob:
    
    linux_t kernel = reinterpret_cast<linux_t>(zImage);

And finally, everything simply falls into place, in an elegance atypical of
embedded systems development:

    kernel(0, ~0, dtb_address);

Woo-hoo! We're done, right? I wish. Compiling the
[kernel](https://github.com/librepi/linux) itself is not such a big deal, if
enough peripherals are disabled to the point of uselessness. Minimally, we
should expect to see *something*. I'd settle for an error message right now...
but nope! Just silence. I swear, I made sure `earlyprintk` was enabled and
setup for the Raspberry Pi's UART, the PL011 -- oh, shoot. Houston, we have a
problem.

For those who are not familiar, a [UART](https://en.wikipedia.org/wiki/UART) is
a chip that lets a computer easily communicate with a serial port. This is
nice, because it is *really* easy to setup a UART on most architectures, and
the protocol is ubiquitous, so it can be used for debugging all sorts of
appliances. Kristina's firmware had alreay setup the UART for debug, and with
the appropriate [USB-to-serial cable](https://www.adafruit.com/products/954),
it's a piece of cake to play with in `screen` or `minicom`. So, why won't Linux
use it? Well, it turns out that the Raspberry Pi actually has *two* UARTs on
board, not just one. The main UART (a PL011) is used by Linux, both for
`earlyprintk` and generally for the system. The auxillary UART, on the other
hand, is not normally used, although for simplicity Kristina chose to use it
instead, ignoring bring-up for the "real" UART. At this point, we'll need to
write a new driver for this chip and migrate the low-level, two-thousand line
project to it. OK, I'm exaggerating the complexity a bit; the registers are
accessed slightly differently, and initialisation requires additional clocking,
but honestly it's not a big deal, and the
[code](https://github.com/christinaa/rpi-open-firmware/blob/master/romstage.c#L25-L73)
is fairly standard for bare-metal Raspberry Pi development. OK, *now* we should
be done... right?

Well, depends how you define 'done', of course! Indeed, we can now verify that
Linux is beginning its early boot process, and if you're lucky, your console
will be flooded by debug information from the kernel. But it won't boot, yet,
since there *isn't* a userspace *to* boot. Remember, on our massive purge to
compile a minimal kernel as fast as possible, we ignored even the SD card
driver. That's a bit of a problem, no?

So, first things first, let's build a minimal environment, since initialising a
full GNU/Linux system will likely convolute this further. Instead, it is pretty
easy to build a [BusyBox](https://www.busybox.net/) binary, which is enough to
act as an initial ramdisk (statically linked into the kernel via a special
configuration option, to avoid adding another phase to the bootloader). And
yes, in theory if the command-line option `rdinit=/bin/sh` is added, you *will*
boot to a shell! Hooray Linux!

But let's not stop here -- I did mention the SD card driver was a big deal. We
can enable this driver from `menuconfig`, and compile the kernel, and --- oh
no, missing symbols! `rpi_firmware_xyz` where `xyz` is a handful of functions.
Did we forget a driver? Not quite; these are from the mailbox interface. In
particular, the stock firmware exposes a
[handful](https://github.com/raspberrypi/firmware/wiki/Mailbox-property-interface)
of helper functions, akin to the BIOS on the PC architecture, to provide for
functions that the kernel can't (or in this case, won't) support itself. Now,
this *is* a problem, since we're not *using* the stock firmware. We could mimic
the API, of course, and implement all of those methods ourselves, and while
this would let us use, say, U-Boot without ports, it would be a *huge* amount
of work, for little gain. Instead, it turns out much of this is *also*
implemented in Linux, and it just *optionally* uses the firmware. Reading
between the lines a bit, we can just comment out a bit of code, and the SD card
driver will compile happily, and even work, mostly. There are some outstanding
bugs regarding the SD card driver, although I suspect this issue is in
Kristina's territory now. Nonetheless, you can mount the SD card from the
BusyBox ramdisk and chroot into Debian, if you'd like. `vim` works surprisingly
well at 115200 baud! Similar patches (and additional firmware bring-up) would
be necessary in the future for more peripherals, like USB or Ethernet.

But hey, two thousand words later, Linux boots. Next time, remind me to try a
*microkernel*.
