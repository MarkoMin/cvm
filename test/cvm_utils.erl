-module(cvm_utils).

-export([test/1]).

test(List) ->
    Len = length(List),

    CVM0 = cvm:new(Len),
    CVM1 = cvm:bulk_insert(List, CVM0),
    CVMCap = cvm:capacity(CVM1),
    CVMCnt = cvm:est(CVM1),
    TrueCnt = naive(List),
    io:format(user,"Total elements: ~p, Capacity: ~p, True distinct count: ~p, EST dirstinct count: ~p~n", [Len, CVMCap, TrueCnt, CVMCnt]),
    Err = CVMCnt-TrueCnt,
    ErrPctg = (abs(Err) / CVMCnt) * 100,
    io:format(user,"Error: ~p (~.2f %)~n", [Err, ErrPctg]).

naive(List) ->
    sets:size(sets:from_list(List)).
