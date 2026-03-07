% ============================
% Entry Point (called via -g main by launcher)
% ============================

main :-
    current_prolog_flag(argv, Argv),
    catch(dispatch(Argv), _, halt(1)).

dispatch([init]) :- !, cmd_init.
dispatch([add, File]) :- !, cmd_add(File).
dispatch([commit, '-m', Msg]) :- !, cmd_commit(Msg).
dispatch([log]) :- !, cmd_log.
dispatch(_) :-
    write('Unknown command'), nl, halt(1).

% ============================
% MiniHash (FNV-1a variant, 64-bit)
% ============================

minihash(Bytes, Hash) :-
    H0 is 1469598103934665603,
    Mod is 18446744073709551616,
    minihash_loop(Bytes, H0, Mod, H),
    format(atom(Hash), '~`0t~16r~16|', [H]).

minihash_loop([], H, _, H).
minihash_loop([B|Bs], H0, Mod, H) :-
    H1 is (H0 xor B) * 1099511628211 mod Mod,
    minihash_loop(Bs, H1, Mod, H).

% ============================
% File I/O Helpers
% ============================

read_file_bytes(File, Bytes) :-
    open(File, read, S, [type(binary)]),
    read_stream_bytes(S, Bytes),
    close(S).

read_stream_bytes(S, Bytes) :-
    get_byte(S, B),
    (   B =:= -1
    ->  Bytes = []
    ;   Bytes = [B|Rest],
        read_stream_bytes(S, Rest)
    ).

write_file_bytes(File, Bytes) :-
    open(File, write, S, [type(binary)]),
    forall(member(B, Bytes), put_byte(S, B)),
    close(S).

read_file_atoms(File, Atoms) :-
    (   exists_file(File)
    ->  open(File, read, S),
        read_lines_to_atoms(S, Atoms),
        close(S)
    ;   Atoms = []
    ).

read_lines_to_atoms(S, Atoms) :-
    read_line_to_string(S, Line),
    (   Line == end_of_file
    ->  Atoms = []
    ;   atom_string(A, Line),
        (   A == ''
        ->  read_lines_to_atoms(S, Atoms)
        ;   Atoms = [A|Rest],
            read_lines_to_atoms(S, Rest)
        )
    ).

read_line_to_atom(S, Atom) :-
    read_line_to_string(S, Str),
    (   Str == end_of_file
    ->  Atom = end_of_file
    ;   atom_string(Atom, Str)
    ).

create_empty_file(Path) :-
    open(Path, write, S),
    close(S).

% ============================
% cmd: init
% ============================

cmd_init :-
    (   exists_directory('.minigit')
    ->  write('Repository already initialized'), nl
    ;   make_directory('.minigit'),
        make_directory('.minigit/objects'),
        make_directory('.minigit/commits'),
        create_empty_file('.minigit/index'),
        create_empty_file('.minigit/HEAD')
    ).

% ============================
% cmd: add
% ============================

cmd_add(File) :-
    (   exists_file(File)
    ->  read_file_bytes(File, Bytes),
        minihash(Bytes, Hash),
        atomic_list_concat(['.minigit/objects/', Hash], ObjPath),
        (   exists_file(ObjPath) -> true ; write_file_bytes(ObjPath, Bytes) ),
        read_file_atoms('.minigit/index', Lines),
        (   member(File, Lines)
        ->  true
        ;   open('.minigit/index', append, IS),
            writeln(IS, File),
            close(IS)
        )
    ;   write('File not found'), nl,
        halt(1)
    ).

% ============================
% cmd: commit
% ============================

cmd_commit(Msg) :-
    read_file_atoms('.minigit/index', Files),
    (   Files = []
    ->  write('Nothing to commit'), nl, halt(1)
    ;   read_head(Parent),
        get_time(TS0),
        TS is truncate(TS0),
        maplist(get_file_hash_pair, Files, Pairs),
        msort(Pairs, SortedPairs),
        with_output_to(atom(Content), (
            format("parent: ~w~n", [Parent]),
            format("timestamp: ~w~n", [TS]),
            format("message: ~w~n", [Msg]),
            format("files:~n"),
            maplist([F-H]>>(format("~w ~w~n", [F, H])), SortedPairs)
        )),
        atom_codes(Content, ContentCodes),
        minihash(ContentCodes, CommitHash),
        atomic_list_concat(['.minigit/commits/', CommitHash], CommitPath),
        open(CommitPath, write, CS),
        write(CS, Content),
        close(CS),
        open('.minigit/HEAD', write, HS),
        write(HS, CommitHash), nl(HS),
        close(HS),
        create_empty_file('.minigit/index'),
        format("Committed ~w~n", [CommitHash])
    ).

read_head(Head) :-
    (   exists_file('.minigit/HEAD')
    ->  open('.minigit/HEAD', read, S),
        read_line_to_string(S, Line),
        close(S),
        (   (Line == end_of_file ; Line == "")
        ->  Head = 'NONE'
        ;   atom_string(Head, Line)
        )
    ;   Head = 'NONE'
    ).

get_file_hash_pair(File, File-Hash) :-
    read_file_bytes(File, Bytes),
    minihash(Bytes, Hash).

% ============================
% cmd: log
% ============================

cmd_log :-
    read_head(Head),
    (   Head == 'NONE'
    ->  write('No commits'), nl
    ;   print_commits(Head)
    ).

print_commits('NONE') :- !.
print_commits(Hash) :-
    atomic_list_concat(['.minigit/commits/', Hash], CommitPath),
    (   exists_file(CommitPath)
    ->  open(CommitPath, read, S),
        read_line_to_atom(S, ParentLine),
        read_line_to_atom(S, TSLine),
        read_line_to_atom(S, MsgLine),
        close(S),
        atom_concat('parent: ', Parent, ParentLine),
        atom_concat('timestamp: ', TSAtom, TSLine),
        atom_concat('message: ', Msg, MsgLine),
        format("commit ~w~nDate: ~w~nMessage: ~w~n~n", [Hash, TSAtom, Msg]),
        print_commits(Parent)
    ;   true
    ).
