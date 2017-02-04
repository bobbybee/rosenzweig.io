Solving BIT Magic
==================
_23 Oct 2016_

Static code recompilation is a fascinating problem -- and largely an unsolved one, because in general it's [impossible](https://en.wikipedia.org/wiki/Halting_problem) (That's about as hard as you can get!) Nevertheless, it's possible in many cases, if you ignore certain features like self-modifying code. Andrew Kelly has written a fantastic [blog post](http://andrewkelley.me/post/jamulator.html) on recompiling NES games to LLVM bitcode. If you haven't read it, you should. It's awesome. Seriously, close this page and read it... but come back here when you're done :-)

---

In his blog post, he mentions several obstacles he faced in his project requiring him to resort to emulation. Maybe he's not wrong; maybe there are too many "dirty assembly tricks" for the project to work. But I'd like to debunk just one of them as an obstacle to static recompilation: BIT magic. Consider the code sample from Super Mario Bros 1 that he uses:

    Label_8220:
        LDY #$00
        .db $2c
    Label_8223:
        LDY #$04
        LDA #$f8
    Label_8227:
        STA $0200, Y
        INY
        INY
        INY
        INY
        BNE Label_8227
        RTS

For context, `$2c` is the BIT absolute instruction, an effective three-byte no-op in this case. That is, if you call `Label_8220`, Y will be set to zero and the two-byte `LDY #$04` line will be, as Andrew says, "sabotaged". It's a tough situation to be in; the original author gave up at this point, deciding that interpreting `Label_8220` is the only viable solution.

---

It turns out he gave up too early. After all, was the fundamental issue that absolute bit tests could not be recompiled? No, of course not, absolute bit tests are pretty easy as far as the 6502 instruction set is concerned. It was that the disassembly of the routine was incomplete. In other words, _there is no organic way to construct this sequence of opcodes in assembly_. This is no big deal for an emulator, which only considers sequences of opcodes to interpret, but at the heart of Andrew's system was his disassembler, an early decision that perhaps led to his project's late death. 

How else might we approach the problem of static recompilation, without beginning with a disassemled binary? One solution is pretty simple, actually: rather than disassembling the entire file by traversing code blocks, disassemble all of the code blocks seperately, regardless of whether they overlap. This modified algorithm is implemented pretty much identically to the original disassembler, but rather than starting out with all `db`'s and filling in gradually, you start out with an empty hashmap of labels to disassembled code blocks and fill in the hashmap block-by-block.

Assuming that both `Label_8220` and `Label_8223` are called or jumped to somewhere in the program, what would the new algorithm produce? Three blocks. The (synthetic) listings are shown below:


    Label_8220:
        LDY #$00
        BIT $04A0
        LDA #$f8
        STA $0200, Y
        INY
        INY
        INY
        INY
        BNE Label_8227
        RTS
     
    Label_8223:
        LDY #$04
        LDA #$f8
        STA $0200, Y
        INY
        INY
        INY
        INY
        BNE Label_8227
        RTS

    Label_8227:
        STA $0200, Y
        INY
        INY
        INY
        INY
        BNE Label_8227
        RTS


There's quite a bit of code repetition, which is unfortunate. But hey, each of these code blocks can individually be compiled pretty easily. What's more, the BIT instruction can likely be optimized out, due to its relative lack of side effects.

---

Maybe there's light at the end of the statically-recompiled tunnel.
