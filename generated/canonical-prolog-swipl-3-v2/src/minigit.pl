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
% Commit parsing helpers
% ============================================================

parse_commit(Hash, Parent, TS, Message, Pairs) :-
    commit_path(Hash, CPath),
    open(CPath, read, S),
    read_all_lines(S, Lines),
    close(S),
    Lines = [L1, L2, L3, _FilesHeader | FileLines],
    atom_concat('parent: ',    Parent,  L1),
    atom_concat('timestamp: ', TSAtom,  L2),
    atom_number(TSAtom, TS),
    atom_concat('message: ',   Message, L3),
    parse_file_lines(FileLines, Pairs).

parse_file_lines([], []).
parse_file_lines([L|Ls], [F-H|Rest]) :-
    L \= '',
    atomic_list_concat([F, H], ' ', L), !,
    parse_file_lines(Ls, Rest).
parse_file_lines([_|Ls], Rest) :-
    parse_file_lines(Ls, Rest).

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
% cmd_status
% ============================================================

cmd_status :-
    read_staged(Staged),
    write('Staged files:'), nl,
    (Staged == [] ->
        write('(none)'), nl
    ;
        maplist([F]>>(write(F), nl), Staged)
    ).

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
% cmd_diff
% ============================================================

cmd_diff(C1, C2) :-
    commit_path(C1, P1), commit_path(C2, P2),
    ((\+ exists_file(P1)) ; (\+ exists_file(P2))), !,
    write('Invalid commit'), nl,
    fail.
cmd_diff(C1, C2) :-
    parse_commit(C1, _, _, _, Pairs1),
    parse_commit(C2, _, _, _, Pairs2),
    diff_pairs(Pairs1, Pairs2).

diff_pairs(Pairs1, Pairs2) :-
    % Find added (in Pairs2, not in Pairs1)
    forall(member(F2-_, Pairs2),
           (member(F2-_, Pairs1) -> true ; format("Added: ~w~n", [F2]))),
    % Find removed (in Pairs1, not in Pairs2)
    forall(member(F1-_, Pairs1),
           (member(F1-_, Pairs2) -> true ; format("Removed: ~w~n", [F1]))),
    % Find modified (same file, different hash)
    forall(member(F-H1, Pairs1),
           (member(F-H2, Pairs2), H1 \= H2 -> format("Modified: ~w~n", [F]) ; true)).

% ============================================================
% cmd_checkout
% ============================================================

cmd_checkout(Hash) :-
    commit_path(Hash, CPath),
    (\+ exists_file(CPath) ->
        write('Invalid commit'), nl,
        fail
    ;
        parse_commit(Hash, _, _, _, Pairs),
        maplist(restore_file, Pairs),
        open('.minigit/HEAD', write, HS),
        write(HS, Hash),
        close(HS),
        open('.minigit/index', write, IS), close(IS),
        format("Checked out ~w~n", [Hash])
    ).

restore_file(File-BlobHash) :-
    obj_path(BlobHash, BlobPath),
    read_file_to_codes(BlobPath, Codes, [encoding(octet)]),
    open(File, write, S, [encoding(octet)]),
    maplist(put_code(S), Codes),
    close(S).

% ============================================================
% cmd_reset
% ============================================================

cmd_reset(Hash) :-
    commit_path(Hash, CPath),
    (\+ exists_file(CPath) ->
        write('Invalid commit'), nl,
        fail
    ;
        open('.minigit/HEAD', write, HS),
        write(HS, Hash),
        close(HS),
        open('.minigit/index', write, IS), close(IS),
        format("Reset to ~w~n", [Hash])
    ).

% ============================================================
% cmd_rm
% ============================================================

cmd_rm(File) :-
    read_staged(Staged),
    (member(File, Staged) ->
        delete(Staged, File, NewStaged),
        open('.minigit/index', write, S),
        maplist([F]>>(writeln(S, F)), NewStaged),
        close(S)
    ;
        write('File not in index'), nl,
        fail
    ).

% ============================================================
% cmd_show
% ============================================================

cmd_show(Hash) :-
    commit_path(Hash, CPath),
    (\+ exists_file(CPath) ->
        write('Invalid commit'), nl,
        fail
    ;
        parse_commit(Hash, _, TS, Message, Pairs),
        format("commit ~w~n", [Hash]),
        format("Date: ~w~n",  [TS]),
        format("Message: ~w~n", [Message]),
        write('Files:'), nl,
        sort(Pairs, Sorted),
        maplist([F-H]>>(format("  ~w ~w~n", [F, H])), Sorted)
    ).

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
run([status|_]) :- !,
    cmd_status, halt(0).
run([log|_]) :- !,
    cmd_log, halt(0).
run([diff, C1, C2|_]) :- !,
    (cmd_diff(C1, C2) -> halt(0) ; halt(1)).
run([checkout, Hash|_]) :- !,
    (cmd_checkout(Hash) -> halt(0) ; halt(1)).
run([reset, Hash|_]) :- !,
    (cmd_reset(Hash) -> halt(0) ; halt(1)).
run([rm, File|_]) :- !,
    (cmd_rm(File) -> halt(0) ; halt(1)).
run([show, Hash|_]) :- !,
    (cmd_show(Hash) -> halt(0) ; halt(1)).
run(_) :-
    write('Unknown command'), nl,
    halt(1).
