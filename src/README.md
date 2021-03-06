The "EqualsEquals" compiler
-------------------

Coded in OCaml, the "EqualsEquals" (aka "eqeq") language is designed for simple
mathematical equation evaluation. For more details, see its [Reference Manual]
_("LRM" for "Language [RM]" in code and comments)_.

- [Status](#status-)
- [Coding, Building, Testing](#coding-building-testing)
  - [Faster Code & Test Cycle](#faster-code--test-cycle)
  - [Writing Tests](#writing-tests)
  - [Debugging Compiler's Phases](#debugging-compilers-phases)
    - [Scanner: Tokens We Generate](#scanner-tokens-we-generate)
    - [Parser: Our Grammar](#parser-our-grammar)
    - [SAST: Our Semantically-Checked AST](#sast-our-semantically-checked-ast)
    - [Codegen: EqualsEquals compiler itself](#codegen-equalsequals-compiler-itself)
  - [One-time Setup](#one-time-setup)
    - [Quickstart](#quickstart)

## Status [![Build Status][buildbadge]][travisci]

Currently we're working towards a ["LRM feature complete" milestone][milestone]; eg:

 - [x] **fixed** ~~in testing: keeping our build passing at every commit on `master` branch~~
 - [x] **fixed** ~~in issues #12 #15:~~
      - ~~make real phases~~
      - ~~replace [_hard-coded behaviour_][dummycodegen]~~
 - [x] **adding new** [tests for each new feature](#writing-tests)
 - [x] **more interesting**: [semantic analysis:#24][GH24] and [code generation:#14][GH14]
 - [x] Unraveling [TODOs] and large [meta-issues]

## Coding, Building, Testing

To **code**, please see [contributing](CONTRIBUTING.md) quickguide.

To **build**, simply: `make`

To run **all end-to-end checks**, simply: `make e2e`.
- or just run `make lint` to see non-test checks
- or just run `make test` to see input/output checks:

  ```sh
  $ make test # or: `make TEST_OPTS=-h test` or any other options it takes

  #... {clean, build, etc.}-output snipped...

  Running 1 tests:
          tests/test-helloworld.eq,
  [1] "test-helloworld"   asserting target's behavior             Result: PASS

  Summary: PASSED
  ```

### Faster Code & Test Cycle

**tl;dr** make use of the `TEST_OPTS=...` flag of `make test`

```
$ time { make test; }

# ... `make test` output snipped...

Summary of 118 tests:   9 SKIPPED       109 PASSED [87%]

real    0m10.697s
user    0m1.660s
sys     0m0.868s
```

**Problem**: With over a 100 tests, you might want to punt a full `make test`
for later. When you're writing code, you might benefit from **just running your
own tests** _(plus a few super-simple general tests you'd like to see break,
immediately)_.

**Solution**: say you're developing "cool feature" against two new test files,
`fail-cool-feature.eq` and `test-cool-feature.eq` and you want to know
*immediately* if you break `test-helloworld.eq`:

```
$ make TEST_OPTS='-v tests/*cool-feature*.eq tests/test-helloworld.eq' test
Running 3 tests:
  "cool feature"       "cool feature"
  "helloworld"
[ 1] "test-cool-feature"       asserting target's behavior      Result: PASS
[ 2] "fail-cool-feature"       asserting compilation fails      Result: PASS
[ 3] "test-helloworld"         asserting target's behavior      Result: PASS

Summary of 3 tests:     3 PASSED [100%]
```

### Writing Tests
So you wrote a feature, like... a `CrazyNewKeyword` that shuts down user's
computer? Great! Do this:
```sh
$ $EDIT tests/test-crazynewkeyword.eq
  # ... ideal case, capturing the complexity you've added (a correct program)

$ $EDIT tests/test-crazynewkeyword.out
  # ... what your example compiled eq C program should do (just the output)
$ make test # ensure its result is "PASS"!

$ $EDIT tests/fail-crazynewkeyword.eq
  # ... any misuse you can think of (an incorrect program)
$ $EDIT tests/fail-crazynewkeyword.err
  # ... how our compiler should complain for your example eq source
$ make test # ensure its result is "PASS"!
```

Note: currently we're trying to only test the behavior of our *compiled* C
programs _(that is: we're not testing what our compiler outputs, but what its
output programs do)_.

### Debugging Compiler's Phases

#### Scanner: Tokens We Generate
To see what our scanner thinks of source programs, with `debugtokens` target:
```sh
$ make debugtokens && ./debugtokens.native < tests/test-helloworld.eq
# .. snipped ...
CTX
ASSIGN
LBRACE
ID
ASSIGN
LBRACE
# ... snipped ....
ID
LPAREN
STRLIT
COMMA
ID
RPAREN
SEMI
RBRACE
```

#### Parser: Our Grammar
Interactive mode with menhir and our parser:
```sh
$ menhir --interpret --interpret-show-cst parser.mly # note missing ASSIGN
CTX LBRACE ID ASSIGN LITERAL SEMI RBRACE

REJECT
```

#### SAST: Our Semantically-Checked AST
To see the output of our semantic analysis ([as of]):
```bash
make && ./eqeq.native -s < $YOUR_TEST_FILE
```
[as of]: https://github.com/rxie25/PLT2016Spring/commit/6e908c68afdec6fe183db3170f43dddd4c69d11c

#### Codegen: EqualsEquals compiler itself
To get the generated C code (ie. the output of code gen):
```bash
make && ./eqeq.native < $YOUR_TEST_FILE
```

### One-time Setup

The above assumes you've done the one-time installation of dependencies for your
machine, thoroughly documented in `./INSTALL`

#### Quickstart

Can't remember if you've done the one-time setup on your machine?

1. Make sure `git status` shows you're in a clean copy of this repo
2. If you can do the below with all tests passing _(obviously)_ then you
  already setup your machine:
```bash
git checkout 1548af6bc79197445a203 &&
  make test &&
  make clean >/dev/null &&
  git checkout master
```

[buildbadge]: https://travis-ci.org/rxie25/PLT2016Spring.png?branch=master
[travisci]: https://travis-ci.org/rxie25/PLT2016Spring
[milestone]: https://github.com/rxie25/PLT2016Spring/milestones/LRM%20Feature%20Complete
[Reference Manual]: ../notes/language-reference-manual.md
[dummycodegen]: https://github.com/rxie25/PLT2016Spring/blob/85e99570cd813398/src/codegen.ml#L14-L16
[GH24]: https://github.com/rxie25/PLT2016Spring/issues/24
[GH14]: https://github.com/rxie25/PLT2016Spring/issues/14
[meta-issues]: https://github.com/rxie25/PLT2016Spring/issues?q=is%3Aissue+is%3Aopen+label%3A%22issue+compilation%22
[TODOs]: https://github.com/rxie25/PLT2016Spring/search?utf8=%E2%9C%93&q=TODO
