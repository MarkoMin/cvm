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
    cvm_utils:test(Ns).

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
    cvm_utils:test(Words).
