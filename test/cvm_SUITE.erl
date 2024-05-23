-module(cvm_SUITE).

-include_lib("common_test/include/ct.hrl").

-compile(nowarn_export_all).
-compile(export_all).

suite() -> 
    [{timetrap, {minutes,5} }].

all() -> [random, hamlet].

groups() -> [].

init_per_suite(Config) ->
    Config.

end_per_suite(_Config) ->
    ok.

init_per_group(_Name, Config) ->
    Config.

end_per_group(_Name, _Config) ->
    ok.

init_per_testcase(_Name, Config) -> Config.

end_per_testcase(_Name, _Config) -> ok.

random(_Config) ->
    Ns = [rand:uniform(4444) || _ <- lists:duplicate(30000, undefined)],
    test(Ns).

hamlet(Config) ->
    Hamlet = filename:join(?config(data_dir,Config), "hamlet.txt"),
    {ok, Txt} = file:read_file(Hamlet),
    Lines = binary:split(Txt, <<"\n">>, [trim, trim_all, global]),
    Words0 = lists:append(
              [binary:split(Line, <<"\s">>, [trim, trim_all, global]) || Line <- Lines]),
    Words = lists:map(fun(Word0) ->
                            Str0 = binary_to_list(Word0),
                            Str = string:lowercase(Str0),
                            case hd(string:reverse(Str)) of
                                $, ->
                                    string:reverse(tl(string:reverse(Str)));
                                $. ->
                                    string:reverse(tl(string:reverse(Str)));
                                $? ->
                                    string:reverse(tl(string:reverse(Str)));
                                $! ->
                                    string:reverse(tl(string:reverse(Str)));
                                $: ->
                                    string:reverse(tl(string:reverse(Str)));
                                _ ->
                                    Str
                            end
                    end,
                      Words0),
    test(Words).

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
