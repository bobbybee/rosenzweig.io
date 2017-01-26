Metaprogramming NES emulator with tosh
=================
_25 Jan 2016_

Over the summer, I wrote an NES emulator in Scratch. Well, really, it was only _from_ Scratch; the code itself was written in [tosh](https://tosh.tjvr.org/) by [Tim Radvan](https://scratch.mit.edu/users/blob8108). tosh is a text-based front-end to Scratch, which lets me manage large projects with vim, git, and -- wait for it -- metaprogramming! Metaprogramming, in its essence, means generating tosh code from other bits of tosh code to construct large programs with minimum effort. In ScratchNES, I used metaprogramming to generate the CPU emulator for the NES. It's not magic!

At the heart of the NES is the [Ricoh 2A03](https://en.wikipedia.org/wiki/Ricoh_2A03), featuring [6502](https://en.wikipedia.org/wiki/6502) missing decimial mode and some support code. The 6502 in turn was a popular 8-bit CPU governed by a simple instruction set, with a variety of instructions and a handful of addressing modes. The Virtual 6502 project maintains a nice [reference](http://e-tradition.net/bytes/6502/6502_instruction_set.html) for the instruction set which you might like to check out. In any event, there are a handful of ways of interpreting this instruction set. The first (and perhaps the most intuitive) way is to notice the patterns in opcode encoding, and intelligently decode instructions like the original [PLA](https://en.wikipedia.org/wiki/Programmable_logic_array) would. While this is a nice idea, it's rather complex and [slow](https://scratch.mit.edu/projects/43692156/) in Scratch. Sorry, tried that last time!

Another possible technique, a technique which is rather popular for emulators in general, would be to manually decode opcodes, starting from a massive, handwritten if-else chain. Sorry, unrolling that much code by hand is _so_ 2016. This leaves us the masochistic third choice -- generate code!

From here, the path is rather clear. We write out stubs for each [addressing modes](https://github.com/bobbybee/ScratchNES/tree/master/src/CPU/addressing) and each [instruction](https://github.com/bobbybee/ScratchNES/tree/master/src/CPU/instructions), in addition to stub-generators for [increased](https://github.com/bobbybee/ScratchNES/blob/master/src/CPU/branch-maker.js) [indirection](https://github.com/bobbybee/ScratchNES/blob/master/src/CPU/build-crement.js) and [insanity](https://github.com/bobbybee/ScratchNES/blob/master/src/CPU/build-transfer.js). From here, we just need to write a program to [stitch](https://github.com/bobbybee/ScratchNES/blob/master/src/CPU/build-cpu.js) the code together. But how _do_ we at least tell the code-generator which opcodes correspond to which addressing modes and instructions? Even though it would probably take ten minutes, why waste another bad idea?

Remember that tabular instruction set reference I linked above? It follows a rather regular structure. We can write a simple [parser](https://github.com/bobbybee/ScratchNES/blob/master/src/CPU/parse-reference.js) for that file, emitting the instruction table for the metaprogrammer. The final question is how to efficient map from opcodes to tosh code at runtime. Normally, jump tables are preferred here, but Scratch, unlike its sister [Snap!](http://byob.berkeley.edu), unfortunately lacks first-class functions. The naive solution would be an if-else chain. For four opcodes, this might look something like:

    if x = 0 then
        op ABC
    else if x = 1 then
        op DEF
    else if x = 2 then
        op GHI
    else if x = 3 then
        op JKL
    end

Unfortunately, this solution is linear to the number of opcodes. That means, it would take 256 comparisons to execute one `BRK` instruction! We can do better use a binary search. This way, it will only take 8 comparisons:

    if x > 1
        if x > 2
            op JKL
        else
            op GHI
        end
    else
        if x > 0
            op DEF
        else
            op ABC
        end
    end

Admittedly, the code isn't the prettiest, but that's alright, since we can using yet another bit of meta-programming to generate that for us too! With this final insight and some messy glue code, we have a mostly-performant, mostly-functional CPU emulator!

That being said, I _did_ promise an NES emulator, not a 6502 emulator or an NES CPU emulator or a Ricoh 2A03 emulator. There are a number of peripherals: the PPU for graphics, the APU for sound, joystick logic, and memory mappers. I won't discuss the details of these implementations here since they are fairly standard as far as NES emulators go. If this is interesting to you, see the [NESDev wiki](https://wiki.nesdev.com/w/index.php/Nesdev_Wiki). As long as the CPU emulator maintains a cycle count internally -- which is relatively easy to add, since cycles are listed in the reference -- these modules are separate. With a lot of sweat later, you'll converge on a working [emulator](https://scratch.mit.edu/projects/141205192/)!

Where to now? It turns out that for all of the fun you can have emulating a 6502, the CPU isn't the bottleneck in the emulator. The real issue is the PPU (graphics), since Scratch is _slow_. Thanks to pen quirks, even [phosphorus](https://phosphorus.github.io/) renders slowly. Nevertheless, this does demonstrate metaprogramming with Scratch is possible, if not particularly useful! Going forward, a natural optimization is [static recompilation](http://andrewkelley.me/post/jamulator.html), where a particular game is compiled directly as opposed to a generic emulator. And since our CPU core is encapsulated so nicely, separating instructions and addressing modes from the general logic, much of the infrastructure is already there as [mentioned](https://scratch.mit.edu/discuss/topic/192915/?page=23#post-2410604) by [Graham Toal](https://scratch.mit.edu/users/gtoal/). There's still quite a few difficulties posed, especially with a fast PPU -- but if you're using static recompilation, perhaps CHR-ROM could turn into costumes and sprites into clones? Either way, it would certainly be a fun project for the industrious reader!

<small>To a friend of mine -- you know who you are -- tosh!  Tosh tosh, tosh tosh tosh, tosh :-)</small>
