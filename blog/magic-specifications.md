Magic Specifications
=================
_2 Feb 2017_

Natural language programming is every programmer's dream. In constrained
situations, it *is* possible, notably used in [Wolfram
Alpha](http://www.wolframalpha.com/) among others. But for everyday work, it is
still far-fetched and awkward; the primary issue is simply that natural
language is
[ambiguous](http://www.seasite.niu.edu/trans/articles/Language%20Ambiguity.htm).
Trying to have a computer derive meaning out of a textbook or a coder's
comments is fruitless (at least until [the
singularity](https://en.wikipedia.org/wiki/Technological_singularity)).
Nevertheless, there is one technical document where ambiguity, by its very
nature, is ruthlessly eliminated: the specification.

Specifications are ultimately at the heart of any complex system. In such a
system, the code is largely secondary to the governing document, much to the
frustration of the implementing hackers. They can certainly be -- and often are
-- wordy, dull, and often nonexistent. But when they work, they work.
Unfortunately, even here parsing and compiling a specification is much too
difficult. Sorry for getting your hopes up with comments about ambiguity!
However, hope is not lost.

Ultimately, natural language processing is focused on deriving meaning out of
_words_. But good specifications are rarely *just* words. No, they feature
tables, flow charts, equations, and so on and so forth. The exact flavour of
supporting visuals varies greatly between fields, but in many cases, at least
to a human, they are so much more important than their supporting words. It's
much like comparing code to its comments, which is not a bad metaphor, since
many of these extra bits _do_ map clearly to code.

If you take this idea of mapping metadata ad extremum, you might end up with a
family of visual
[DSLs](https://en.wikipedia.org/wiki/Domain-specific_language). LaTeX math
might map to the expression computing the designated value. A flowchart diagram
written in Dot might generate a finite-state machine. A table of registers from
a chip datasheet might generate a set of macros. Even business logic can often
be decomposed into these components. So much of a given program can be
automatically generated from these Turing incomplete, semantic, often
verifiable, embeddable languages. Maybe even the entirety of a program could be
generated from its natural specification, in an extreme adaptation of literate
programming. But then again, this is just a pipe dream :-)
