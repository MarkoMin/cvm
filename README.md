cvm
=====

Implementation of [CVM](https://www.quantamagazine.org/computer-scientists-invent-an-efficient-new-way-to-count-20240516/) algorithm in Erlang.

Build
-----

    rebar3 compile

Run tests
-----

    rebar3 ct

Run your own examples in REPL
-----

    rebar3 shell
    ...
    1> MyList = [Elem1, Elem2, ...].
    
    2> cvm_utils:test(MyList).


