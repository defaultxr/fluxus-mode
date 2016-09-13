# fluxus-mode
Emacs mode for interfacing with the Fluxus live coding environment.

Forked and heavily modified from https://github.com/lesbroot/fluxus-framework

Please don't hesitate to offer suggestions or let me know about any issues!

Installation
============

Download this repository, then put the following in your init.el:

```
(load "/path/to/fluxus-mode/fluxus-mode.el")
```

And put this in your ~/.fluxus.scm:

```
(load "/path/to/fluxus-mode/fluxus.scm")
```

Then just open a new file in Emacs with the .flx extension (I use this instead of .scm so there's no confusion between other non-Fluxus Schemes) and type C-c C-o to start Fluxus from Emacs!

Usage
=====

- Use C-c C-c to evaluate the current top-level defun in the buffer.
- Use C-c C-f to evaluate the whole buffer.

Future
======

- Get this on MELPA
- Figure out if it's possible to automatically hide Fluxus's on-screen REPL (this will be optional of course)
- Other stuff also.
