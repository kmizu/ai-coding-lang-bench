:- initialization(main, main).

% ============================================================
% MiniHash: FNV-1a variant (64-bit)
% ============================================================

minihash_bytes(Bytes, Hash) :-
    minihash_loop(Bytes, 1469598103934665603, H),
    format(atom(Hash), '~`0t~16r~16|', [H]).

minihash_loop([], H, H).
minihash_loop([B|Bs], H0, H) :-
    H1 is ((H0 xor B) * 1099511628211) mod 18446744073709551616,
    minihash_loop(Bs, H1, H).

file_minihash(File, Hash) :-
    read_file_to_codes(File, Codes, [encoding(octet)]),
    minihash_bytes(Codes, Hash).

% ============================================================
% Path helpers
% ============================================================

obj_path(Hash, Path) :-
    atom_concat('.minigit/objects/', Hash, Path).

commit_path(Hash, Path) :-
    atom_concat('.minigit/commits/', Hash, Path).

% ============================================================
% Index helpers
% ============================================================

read_staged(Lines) :-
    open('.minigit/index', read, S),
    read_all_lines(S, Lines),
    close(S).

read_all_lines(S, Lines) :-
    read_line_to_string(S, Line),
    (Line == end_of_file ->
        Lines = []
    ;
        atom_string(A, Line),
        read_all_lines(S, Rest),
        Lines = [A|Rest]
    ).

% ============================================================
% HEAD helpers
% ============================================================

read_head(Parent) :-
    open('.minigit/HEAD', read, S),
    read_line_to_string(S, Line),
    close(S),
    (Line == end_of_file -> Parent = 'NONE'
    ; Line = ""          -> Parent = 'NONE'
    ; atom_string(Parent, Line)
    ).

% ============================================================
% cmd_init
% ============================================================

cmd_init :-
    (exists_directory('.minigit') ->
        write('Repository already initialized'), nl
    ;
        make_directory('.minigit'),
        make_directory('.minigit/objects'),
        make_directory('.minigit/commits'),
        open('.minigit/index', write, IS), close(IS),
        open('.minigit/HEAD',  write, HS), close(HS)
    ).

% ============================================================
% cmd_add
% ============================================================

cmd_add(File) :-
    (exists_file(File) ->
        file_minihash(File, Hash),
        obj_path(Hash, BlobPath),
        (exists_file(BlobPath) -> true ; copy_blob(File, BlobPath)),
        stage_file(File)
    ;
        write('File not found'), nl,
        fail
    ).

copy_blob(Src, Dst) :-
    read_file_to_codes(Src, Codes, [encoding(octet)]),
    open(Dst, write, S, [encoding(octet)]),
    maplist(put_code(S), Codes),
    close(S).

stage_file(File) :-
    read_staged(Staged),
    (member(File, Staged) -> true
    ;
        open('.minigit/index', append, S),
        writeln(S, File),
        close(S)
    ).

% ============================================================
% cmd_commit
% ============================================================

cmd_commit(Msg) :-
    read_staged(Staged),
    (Staged == [] ->
        write('Nothing to commit'), nl,
        fail
    ;
        read_head(Parent),
        get_time(T), TS is integer(T),
        file_hash_pairs(Staged, Pairs),
        sort(Pairs, Sorted),
        with_output_to(atom(Content), write_commit_body(Parent, TS, Msg, Sorted)),
        atom_codes(Content, Codes),
        minihash_bytes(Codes, CHash),
        commit_path(CHash, CPath),
        open(CPath, write, CS),
        write(CS, Content),
        close(CS),
        open('.minigit/HEAD', write, HS),
        write(HS, CHash),
        close(HS),
        open('.minigit/index', write, IS), close(IS),
        format("Committed ~w~n", [CHash])
    ).

file_hash_pairs([], []).
file_hash_pairs([F|Fs], [F-H|Rest]) :-
    file_minihash(F, H),
    file_hash_pairs(Fs, Rest).

write_commit_body(Parent, TS, Msg, Pairs) :-
    format("parent: ~w~n",    [Parent]),
    format("timestamp: ~w~n", [TS]),
    format("message: ~w~n",   [Msg]),
    format("files:~n"),
    maplist(write_file_entry, Pairs).

write_file_entry(F-H) :-
    format("~w ~w~n", [F, H]).

% ============================================================
% cmd_log
% ============================================================

cmd_log :-
    read_head(Head),
    (Head == 'NONE' ->
        write('No commits'), nl
    ;
        print_log(Head)
    ).

print_log('NONE') :- !.
print_log(Hash) :-
    commit_path(Hash, CPath),
    open(CPath, read, S),
    read_line_to_string(S, L1),  % parent: XXX
    read_line_to_string(S, L2),  % timestamp: NNN
    read_line_to_string(S, L3),  % message: MSG
    close(S),
    atom_concat('parent: ',    Parent,  L1),
    atom_concat('timestamp: ', TSAtom,  L2),
    atom_number(TSAtom, TS),
    atom_concat('message: ',   Message, L3),
    format("commit ~w~n",  [Hash]),
    format("Date: ~w~n",   [TS]),
    format("Message: ~w~n",[Message]),
    nl,
    print_log(Parent).

% ============================================================
% Entry point
% ============================================================

main :-
    current_prolog_flag(argv, Argv),
    (run(Argv) -> true ; halt(1)).

run([init|_]) :- !,
    cmd_init, halt(0).
run([add, File|_]) :- !,
    (cmd_add(File) -> halt(0) ; halt(1)).
run([commit, '-m', Msg|_]) :- !,
    (cmd_commit(Msg) -> halt(0) ; halt(1)).
run([log|_]) :- !,
    cmd_log, halt(0).
run(_) :-
    write('Unknown command'), nl,
    halt(1).
