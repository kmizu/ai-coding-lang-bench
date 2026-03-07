:- module minigit.
:- interface.
:- import_module io.
:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module list.
:- import_module string.
:- import_module int.
:- import_module uint64.
:- import_module char.
:- import_module dir.
:- import_module pair.

%-----------------------------------------------------------------------------%
% FFI: get Unix timestamp
%-----------------------------------------------------------------------------%

:- pred get_unix_timestamp(int::out, io::di, io::uo) is det.
:- pragma foreign_proc("C",
    get_unix_timestamp(T::out, _IO0::di, _IO::uo),
    [will_not_call_mercury, promise_pure],
    "T = (MR_Integer)time(NULL);").

:- pragma foreign_decl("C", "#include <time.h>").

%-----------------------------------------------------------------------------%

main(!IO) :-
    io.command_line_arguments(Args, !IO),
    ( Args = ["init" | _] ->
        cmd_init(!IO)
    ; Args = ["add", File] ->
        cmd_add(File, !IO)
    ; Args = ["commit", "-m", Message] ->
        cmd_commit(Message, !IO)
    ; Args = ["log"] ->
        cmd_log(!IO)
    ;
        io.write_string("Usage: minigit <command>\n", !IO),
        io.set_exit_status(1, !IO)
    ).

%-----------------------------------------------------------------------------%
% init
%-----------------------------------------------------------------------------%

:- pred cmd_init(io::di, io::uo) is det.
cmd_init(!IO) :-
    io.open_input(".minigit/HEAD", HeadResult, !IO),
    ( HeadResult = ok(S) ->
        io.close_input(S, !IO),
        io.write_string("Repository already initialized\n", !IO)
    ;
        dir.make_directory(".minigit", _, !IO),
        dir.make_directory(".minigit/objects", _, !IO),
        dir.make_directory(".minigit/commits", _, !IO),
        write_file(".minigit/HEAD", "", !IO),
        write_file(".minigit/index", "", !IO)
    ).

%-----------------------------------------------------------------------------%
% add
%-----------------------------------------------------------------------------%

:- pred cmd_add(string::in, io::di, io::uo) is det.
cmd_add(File, !IO) :-
    io.open_input(File, OpenResult, !IO),
    ( OpenResult = ok(Stream) ->
        io.read_file_as_string(Stream, ReadResult, !IO),
        io.close_input(Stream, !IO),
        ( ReadResult = ok(Content) ->
            Hash = mini_hash(Content),
            write_file(".minigit/objects/" ++ Hash, Content, !IO),
            read_file_string(".minigit/index", IndexContent, !IO),
            Lines = string.split_at_char('\n', IndexContent),
            StagedFiles = list.filter(non_empty_string, Lines),
            ( list.member(File, StagedFiles) ->
                true
            ;
                write_file(".minigit/index",
                    IndexContent ++ File ++ "\n", !IO)
            )
        ;
            io.write_string("File not found\n", !IO),
            io.set_exit_status(1, !IO)
        )
    ;
        io.write_string("File not found\n", !IO),
        io.set_exit_status(1, !IO)
    ).

%-----------------------------------------------------------------------------%
% commit
%-----------------------------------------------------------------------------%

:- pred cmd_commit(string::in, io::di, io::uo) is det.
cmd_commit(Message, !IO) :-
    read_file_string(".minigit/index", IndexContent, !IO),
    Lines = string.split_at_char('\n', IndexContent),
    StagedFiles = list.filter(non_empty_string, Lines),
    ( StagedFiles = [] ->
        io.write_string("Nothing to commit\n", !IO),
        io.set_exit_status(1, !IO)
    ;
        read_file_string(".minigit/HEAD", HeadContent, !IO),
        Parent = string.strip(HeadContent),
        ( Parent = "" ->
            ParentStr = "NONE"
        ;
            ParentStr = Parent
        ),
        get_unix_timestamp(TimeInt, !IO),
        list.sort(StagedFiles, SortedFiles),
        get_file_hashes(SortedFiles, FileHashes, !IO),
        FilesLines = list.map(func(F - H) = F ++ " " ++ H, FileHashes),
        FilesStr = string.join_list("\n", FilesLines),
        CommitContent =
            "parent: " ++ ParentStr ++ "\n" ++
            "timestamp: " ++ string.int_to_string(TimeInt) ++ "\n" ++
            "message: " ++ Message ++ "\n" ++
            "files:\n" ++ FilesStr ++ "\n",
        CommitHash = mini_hash(CommitContent),
        write_file(".minigit/commits/" ++ CommitHash, CommitContent, !IO),
        write_file(".minigit/HEAD", CommitHash ++ "\n", !IO),
        write_file(".minigit/index", "", !IO),
        io.write_string("Committed " ++ CommitHash ++ "\n", !IO)
    ).

:- pred get_file_hashes(list(string)::in,
    list(pair(string, string))::out, io::di, io::uo) is det.
get_file_hashes([], [], !IO).
get_file_hashes([File | Files], [File - Hash | Rest], !IO) :-
    read_file_string(File, Content, !IO),
    Hash = mini_hash(Content),
    get_file_hashes(Files, Rest, !IO).

%-----------------------------------------------------------------------------%
% log
%-----------------------------------------------------------------------------%

:- pred cmd_log(io::di, io::uo) is det.
cmd_log(!IO) :-
    read_file_string(".minigit/HEAD", HeadContent, !IO),
    Hash = string.strip(HeadContent),
    ( Hash = "" ->
        io.write_string("No commits\n", !IO)
    ;
        print_log(Hash, !IO)
    ).

:- pred print_log(string::in, io::di, io::uo) is det.
print_log(Hash, !IO) :-
    ( Hash = "" ->
        true
    ; Hash = "NONE" ->
        true
    ;
        read_file_string(".minigit/commits/" ++ Hash, Content, !IO),
        ( Content = "" ->
            true
        ;
            CLines = string.split_at_char('\n', Content),
            get_field(CLines, "timestamp: ", Timestamp),
            get_field(CLines, "message: ", Msg),
            get_field(CLines, "parent: ", ParentVal),
            io.write_string("commit " ++ Hash ++ "\n", !IO),
            io.write_string("Date: " ++ Timestamp ++ "\n", !IO),
            io.write_string("Message: " ++ Msg ++ "\n\n", !IO),
            print_log(ParentVal, !IO)
        )
    ).

%-----------------------------------------------------------------------------%
% MiniHash (FNV-1a variant, 64-bit)
%-----------------------------------------------------------------------------%

:- func mini_hash(string) = string.
mini_hash(Content) = HexStr :-
    Chars = string.to_char_list(Content),
    H0 = uint64.cast_from_int(1469598103934665603),
    list.foldl(update_hash, Chars, H0, HFinal),
    HexStr = uint64_to_hex16(HFinal).

:- pred update_hash(char::in, uint64::in, uint64::out) is det.
update_hash(C, H0, H1) :-
    B = uint64.cast_from_int(char.to_int(C)),
    Xored = uint64.xor(H0, B),
    Multiplier = uint64.cast_from_int(1099511628211),
    H1 = Xored * Multiplier.

:- func uint64_to_hex16(uint64) = string.
uint64_to_hex16(N) = string.from_char_list(nibble_chars(N, 15)).

:- func nibble_chars(uint64, int) = list(char).
nibble_chars(N, I) = Result :-
    ( I < 0 ->
        Result = []
    ;
        Nibble = uint64.cast_to_int((N >> (I * 4)) /\
            uint64.cast_from_int(15)),
        C = nibble_to_char(Nibble),
        Rest = nibble_chars(N, I - 1),
        Result = [C | Rest]
    ).

:- func nibble_to_char(int) = char.
nibble_to_char(N) = C :-
    ( N < 10 ->
        C = char.det_from_int(char.to_int('0') + N)
    ;
        C = char.det_from_int(char.to_int('a') + N - 10)
    ).

%-----------------------------------------------------------------------------%
% Helpers
%-----------------------------------------------------------------------------%

:- pred write_file(string::in, string::in, io::di, io::uo) is det.
write_file(Path, Content, !IO) :-
    io.open_output(Path, Result, !IO),
    ( Result = ok(Stream) ->
        io.write_string(Stream, Content, !IO),
        io.close_output(Stream, !IO)
    ;
        true
    ).

:- pred read_file_string(string::in, string::out, io::di, io::uo) is det.
read_file_string(Path, Content, !IO) :-
    io.open_input(Path, OpenResult, !IO),
    ( OpenResult = ok(Stream) ->
        io.read_file_as_string(Stream, ReadResult, !IO),
        io.close_input(Stream, !IO),
        ( ReadResult = ok(S) ->
            Content = S
        ;
            Content = ""
        )
    ;
        Content = ""
    ).

:- pred get_field(list(string)::in, string::in, string::out) is det.
get_field([], _, "").
get_field([Line | Lines], Prefix, Value) :-
    ( string.remove_prefix(Prefix, Line, Rest) ->
        Value = Rest
    ;
        get_field(Lines, Prefix, Value)
    ).

:- pred non_empty_string(string::in) is semidet.
non_empty_string(S) :- S \= "".
