Gunn Hacks 3.0 Post Mortem
====================
_14 Nov 2016_

Last weekend, [https://github.com/nickolas360](@nickolas360) and I participated in [https://gunnhacks.com](GunnHacks 3.0), a high-school hackathon in Palo Alto. After twenty-four hours of code -- no, we did not plan for time to sleep, a decision I still have not decided if I regret or not -- we finished [https://github.com/nickolas360/markov-complete](markov complete), an analogue to the more traditional tab-complete using Markov chains  instead of contextually appropriate code suggestions. Powered by our (poorly written) [https://github.com/bobbybee/markov](markov libary), we integrated markov complete into `vim` (the only text editor in existence), `weechat` (one of the two IRC clients, along with `irssi`), and GNU readline, a feat Nickolas regrets dearly. 

Now with the Markov plugin enabled, I'm free to write utter non-sense into my blog posts and have the nonsense auto-generated. More so, I can write similarly nonsensical replies to queries on IRC, because nobody has time to chat with their friends when they are so busy spamming the tab key for their blog posts and REPL code comments!

I maintain that I am better at implementation than design. Oh well, I still blame Nickolas for making the decision for me. It was this or word-count-as-a-service, the latest Orwellian affront to your freedom! Oh, wait, I did over lunch, too, in [wings](https://github.com/bobbybee/wings).
