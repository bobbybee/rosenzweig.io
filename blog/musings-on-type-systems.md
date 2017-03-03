Musings on Type Systems
==============
_1 Feb 2017_

Everybody in CS seems to love arguing over type systems. Static vs dynamic,
explicit vs inferred, polymorphism, you name it. Get a Haskell programmer, a
Lisper, a C coder, and a Pythonista in a room together -- I'll grab the
popcorn! Yet, despite the strong opinions, it is easy to lose sight of why
types matter in the first place: types are guarantees on otherwise chaotic
program behaviour.

In other words, types are tiny proofs about the programs. In an explicitly
typed language like C, the programmer really is explicitly making (provable)
assertions about the code. For instance, I might write `uint32_t cakeCount`,
which can then be interpreted as a guarantee that the value of `cakeCount` is
in $\{ x | x \in \mathbb{Z}, 0 \leq x < 2^32 \}$. Why is this (rather verbose)
guarantee useful? To a human, it's probably not. But for the compiler it now
means that `cakeCount` can legally be stored to a 32-bit register. Perhaps that
isn't terribly interesting, since most compilers can avoid the underlying
mathematics for a simple example like this in practice. But it _does_ mean that
a static analysis tool can guarantee, for instance, that iterating with the
`eat` method `cakeCount` times will _always_ halt.

Really, there are two major implications to which a type system leads:
performance characteristics and provable correctness. It is useful to consider
both separately, though the latter is rarely discussed outside of academic
circles, and academia is only concerned with asymptotic performance!
Nevertheless, for performance concerns, these "constraint-style" proofs are
sufficient, e.g.: prove that the variable X will always fit in the register Y.
For correctness, the proofs are somewhat more assertive in nature, e.g.: prove
that the return value of the function F will always be a perfect square. The
former proof is clearly more difficult than the latter, but I digress. The
bottom line is, it would be wonderful if a computer algebra system could
replace [Hindley-Milner](https://en.wikipedia.org/wiki/Hindley-Milner)!

Unfortunately, arbitrary proofs about programs are subject to all sorts of
issues which I [alluded to](https://en.wikipedia.org/wiki/Halting_problem)
above. If I could prove anything, why not, for instance, prove that this
program will always halt? Nevertheless, the scope of the Halting problem is
only Turing-complete languages (which includes everybody's favorites). In
principle, it should be possible to design a non-Turing complete subset of one
of the above languages, subject to limitations such as a guarantee of halting
in a given time, perhaps these proofs _are_ feasible. And sometimes that magic
subset is all you need.
