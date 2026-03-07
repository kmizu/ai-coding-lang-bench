:- initialization(main, main).
:- dynamic main_done/0.

main :-
    ( main_done ->
        true
    ;
        assertz(main_done),
        current_prolog_flag(argv, Argv),
        catch(dispatch(Argv), Error,
              (format(atom(Msg), "Error: ~w", [Error]),
               writeln(Msg),
               halt(1)))
    ).

%-----------------------------------------------------------------------
% Command dispatch
%-----------------------------------------------------------------------

dispatch(['init'|_])             :- !, cmd_init.
dispatch(['add', File|_])        :- !, cmd_add(File).
dispatch(['commit', '-m', Msg|_]):- !, cmd_commit(Msg).
dispatch(['log'|_])              :- !, cmd_log.
dispatch(_) :-
    writeln('Usage: minigit <command>'),
    halt(1).

%-----------------------------------------------------------------------
% init
%-----------------------------------------------------------------------

cmd_init :-
    ( exists_directory('.minigit') ->
        writeln('Repository already initialized')
    ;
        make_directory('.minigit'),
        make_directory('.minigit/objects'),
        make_directory('.minigit/commits'),
        open('.minigit/index', write, IS), close(IS),
        open('.minigit/HEAD',  write, HS), close(HS)
    ).

%-----------------------------------------------------------------------
% add
%-----------------------------------------------------------------------

cmd_add(File) :-
    ( \+ exists_file(File) ->
        writeln('File not found'),
        halt(1)
    ;
        read_file_bytes(File, Bytes),
        minihash(Bytes, Hash),
        atom_concat('.minigit/objects/', Hash, BlobPath),
        ( \+ exists_file(BlobPath) ->
            write_bytes_to_file(BlobPath, Bytes)
        ; true ),
        read_index(Pairs),
        ( member(File-_, Pairs) ->
            true
        ;
            open('.minigit/index', append, S),
            format(S, '~w ~w~n', [File, Hash]),
            close(S)
        )
    ).

%-----------------------------------------------------------------------
% commit
%-----------------------------------------------------------------------

cmd_commit(Msg) :-
    read_index(Pairs),
    ( Pairs = [] ->
        writeln('Nothing to commit'),
        halt(1)
    ;
        read_head(Parent),
        get_time(TimeFloat),
        Timestamp is truncate(TimeFloat),
        keysort(Pairs, SortedPairs),
        maplist(format_file_line, SortedPairs, FileLines),
        atomic_list_concat(FileLines, FilesStr),
        format(atom(CommitContent),
               'parent: ~w~ntimestamp: ~w~nmessage: ~w~nfiles:~n~w',
               [Parent, Timestamp, Msg, FilesStr]),
        atom_codes(CommitContent, Codes),
        minihash(Codes, CommitHash),
        atom_concat('.minigit/commits/', CommitHash, CommitPath),
        open(CommitPath, write, CS),
        write(CS, CommitContent),
        close(CS),
        open('.minigit/HEAD', write, HS),
        format(HS, '~w~n', [CommitHash]),
        close(HS),
        open('.minigit/index', write, IS),
        close(IS),
        format('Committed ~w~n', [CommitHash])
    ).

format_file_line(File-Hash, Line) :-
    format(atom(Line), '~w ~w~n', [File, Hash]).

%-----------------------------------------------------------------------
% log
%-----------------------------------------------------------------------

cmd_log :-
    read_head(Head),
    ( Head = 'NONE' ->
        writeln('No commits')
    ;
        log_from(Head)
    ).

log_from('NONE') :- !.
log_from(Hash) :-
    atom_concat('.minigit/commits/', Hash, CommitPath),
    ( \+ exists_file(CommitPath) ->
        true
    ;
        read_commit(CommitPath, Parent, Timestamp, Message),
        format('commit ~w~n', [Hash]),
        format('Date: ~w~n', [Timestamp]),
        format('Message: ~w~n~n', [Message]),
        log_from(Parent)
    ).

read_commit(Path, Parent, Timestamp, Message) :-
    open(Path, read, S),
    read_line_to_string(S, L1),
    read_line_to_string(S, L2),
    read_line_to_string(S, L3),
    close(S),
    string_concat("parent: ",    ParentStr, L1),
    atom_string(Parent, ParentStr),
    string_concat("timestamp: ", TsStr, L2),
    number_string(Timestamp, TsStr),
    string_concat("message: ",   MsgStr, L3),
    atom_string(Message, MsgStr).

%-----------------------------------------------------------------------
% Index I/O  (format: "<filename> <blobhash>" per line)
%-----------------------------------------------------------------------

read_index(Pairs) :-
    ( exists_file('.minigit/index') ->
        open('.minigit/index', read, S),
        read_index_stream(S, Pairs),
        close(S)
    ;
        Pairs = []
    ).

read_index_stream(S, Pairs) :-
    read_line_to_string(S, Line),
    ( Line = end_of_file ->
        Pairs = []
    ;
        ( string_length(Line, 0) ->
            read_index_stream(S, Pairs)
        ;
            split_string(Line, " ", "", [FileStr, HashStr]),
            atom_string(FileAtom, FileStr),
            atom_string(HashAtom, HashStr),
            read_index_stream(S, Rest),
            Pairs = [FileAtom-HashAtom|Rest]
        )
    ).

%-----------------------------------------------------------------------
% HEAD I/O
%-----------------------------------------------------------------------

read_head(Head) :-
    ( exists_file('.minigit/HEAD') ->
        open('.minigit/HEAD', read, S),
        read_line_to_string(S, Line),
        close(S),
        ( ( Line = end_of_file ; Line = "" ) ->
            Head = 'NONE'
        ;
            atom_string(Head, Line)
        )
    ;
        Head = 'NONE'
    ).

%-----------------------------------------------------------------------
% MiniHash  (FNV-1a variant, 64-bit)
%-----------------------------------------------------------------------

minihash(Bytes, Hash) :-
    Mod   = 18446744073709551616,   % 2^64
    Prime = 1099511628211,
    fnv_fold(Bytes, 1469598103934665603, Mod, Prime, H),
    format(atom(Hash), '~`0t~16r~16|', [H]).

fnv_fold([], H, _, _, H).
fnv_fold([B|Bs], H0, Mod, Prime, H) :-
    H1 is (H0 xor B),
    H2 is (H1 * Prime) mod Mod,
    fnv_fold(Bs, H2, Mod, Prime, H).

%-----------------------------------------------------------------------
% File I/O helpers
%-----------------------------------------------------------------------

read_file_bytes(File, Bytes) :-
    open(File, read, S, [type(binary)]),
    stream_to_bytes(S, Bytes),
    close(S).

stream_to_bytes(S, Bytes) :-
    get_byte(S, B),
    ( B =:= -1 ->
        Bytes = []
    ;
        stream_to_bytes(S, Rest),
        Bytes = [B|Rest]
    ).

write_bytes_to_file(Path, Bytes) :-
    open(Path, write, S, [type(binary)]),
    maplist(put_byte(S), Bytes),
    close(S).
