-module(cvm).

-export([new/1, est/1, capacity/1, insert/2, bulk_insert/2]).

-opaque cvm() :: #{p_inv:=pos_integer(),
                   size:=pos_integer(),
                   elems:=sets:set()}.

-opaque cvm(T) :: #{p_inv:=pos_integer(),
                   size:=pos_integer(),
                   elems:=sets:set(T)}.

%% epsilon > 0
-type epsilon() :: float().
%% delta < 1
-type delta() :: float().

-define(EPSILON, 0.4).
-define(DELTA, 0.2).

-export_type([cvm/0, cvm/1]).

new(Size) ->
    new(Size, ?EPSILON, ?DELTA).

new(Size, Epsilon, Delta) ->
    Capacity = erlang:ceil(
             (12 / math:pow(Epsilon, 2)) *
             math:log2((8*Size)/Delta)
            ),
    #{p_inv => 1,
        capacity => Capacity,
        elems => sets:new()}.

est(#{p_inv:=PInv, elems:=Elems0}) ->
    ElemsCnt = sets:size(Elems0),
    ElemsCnt * PInv.

capacity(#{capacity:=Capacity}) ->
    Capacity.

insert(Elem,
        #{p_inv:=PInv, elems:=Elems0}=CVM0) ->
    Elems1 = sets:del_element(Elem, Elems0),
    Elems = case flip(PInv) of
                tails ->
                    sets:add_element(Elem, Elems0);
                heads ->
                    Elems1
            end,
    maybe_next_round(CVM0#{elems:=Elems}).

bulk_insert(Elems, CVM0) ->
    lists:foldl(fun cvm:insert/2, CVM0,Elems).

maybe_next_round(#{p_inv:=PInv0, elems:=Elems, capacity:=Capacity}=CVM0) -> 
    case sets:size(Elems) of
        Capacity ->
            CVM0#{p_inv:=PInv0*2, elems:= purge_half(Elems)};
        _ ->
            CVM0
    end.

purge_half(Elems) ->
    sets:filter(fun(_) -> flip(2)==heads end, Elems).

%% if PInv is 8, you have 1/8 chance to get tails
flip(HeadsPInv) ->
    case rand:uniform(HeadsPInv) of
        1 -> tails;
        _ -> heads
    end.
