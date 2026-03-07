:- module minigit.
:- interface.
:- import_module io.
:- pred main(io::di, io::uo) is det.

:- implementation.
:- import_module char.
:- import_module dir.
:- import_module int.
:- import_module list.
:- import_module pair.
:- import_module string.
:- import_module uint64.

%-----------------------------------------------------------------------------%
% FFI for Unix timestamp

:- pragma foreign_decl("C", "#include <time.h>").

:- pred get_unix_timestamp(int::out, io::di, io::uo) is det.
:- pragma foreign_proc("C",
    get_unix_timestamp(T::out, _IO0::di, _IO::uo),
    [promise_pure, will_not_call_mercury],
    "T = (MR_Integer) time(NULL);").

%-----------------------------------------------------------------------------%
% Entry point

main(!IO) :-
    io.command_line_arguments(Args, !IO),
    ( Args = ["init" | _] ->
        cmd_init(!IO)
    ; Args = ["add", File | _] ->
        cmd_add(File, !IO)
    ; Args = ["commit", "-m", Msg | _] ->
        cmd_commit(Msg, !IO)
    ; Args = ["log" | _] ->
        cmd_log(!IO)
    ; Args = ["status" | _] ->
        cmd_status(!IO)
    ; Args = ["diff", C1, C2 | _] ->
        cmd_diff(C1, C2, !IO)
    ; Args = ["checkout", Hash | _] ->
        cmd_checkout(Hash, !IO)
    ; Args = ["reset", Hash | _] ->
        cmd_reset(Hash, !IO)
    ; Args = ["rm", File | _] ->
        cmd_rm(File, !IO)
    ; Args = ["show", Hash | _] ->
        cmd_show(Hash, !IO)
    ;
        io.write_string("Unknown command\n", !IO),
        io.set_exit_status(1, !IO)
    ).

%-----------------------------------------------------------------------------%
% init

:- pred cmd_init(io::di, io::uo) is det.
cmd_init(!IO) :-
    io.check_file_accessibility(".minigit", [], Res, !IO),
    ( Res = ok ->
        io.write_string("Repository already initialized\n", !IO)
    ;
        dir.make_directory(".minigit", _, !IO),
        dir.make_directory(".minigit/objects", _, !IO),
        dir.make_directory(".minigit/commits", _, !IO),
        write_text_file(".minigit/index", "", !IO),
        write_text_file(".minigit/HEAD", "", !IO)
    ).

%-----------------------------------------------------------------------------%
% add

:- pred cmd_add(string::in, io::di, io::uo) is det.
cmd_add(File, !IO) :-
    io.check_file_accessibility(File, [read], FileRes, !IO),
    ( FileRes = ok ->
        read_text_file(File, Content, !IO),
        Hash = compute_hash(Content),
        write_text_file(".minigit/objects/" ++ Hash, Content, !IO),
        read_text_file(".minigit/index", IndexStr, !IO),
        Lines = string.split_at_char('\n', IndexStr),
        list.filter_map(parse_index_line, Lines, Entries),
        list.filter(entry_has_file(File), Entries, Existing),
        ( Existing = [_ | _] ->
            NewEntries = list.map(update_entry(File, Hash), Entries)
        ;
            NewEntries = Entries ++ [File - Hash]
        ),
        write_index(NewEntries, !IO)
    ;
        io.write_string("File not found\n", !IO),
        io.set_exit_status(1, !IO)
    ).

%-----------------------------------------------------------------------------%
% commit

:- pred cmd_commit(string::in, io::di, io::uo) is det.
cmd_commit(Msg, !IO) :-
    read_text_file(".minigit/index", IndexStr, !IO),
    Lines = string.split_at_char('\n', IndexStr),
    list.filter_map(parse_index_line, Lines, Entries),
    ( Entries = [] ->
        io.write_string("Nothing to commit\n", !IO),
        io.set_exit_status(1, !IO)
    ;
        list.sort(Entries, SortedEntries),
        read_text_file(".minigit/HEAD", HeadStr, !IO),
        Parent0 = string.strip(HeadStr),
        ( Parent0 = "" -> Parent = "NONE" ; Parent = Parent0 ),
        get_unix_timestamp(Ts, !IO),
        Timestamp = string.from_int(Ts),
        FilesLines = list.map(func(F - H) = F ++ " " ++ H, SortedEntries),
        FilesStr = string.join_list("\n", FilesLines),
        CommitContent =
            "parent: " ++ Parent ++ "\n" ++
            "timestamp: " ++ Timestamp ++ "\n" ++
            "message: " ++ Msg ++ "\n" ++
            "files:\n" ++
            FilesStr ++ "\n",
        CommitHash = compute_hash(CommitContent),
        write_text_file(".minigit/commits/" ++ CommitHash, CommitContent, !IO),
        write_text_file(".minigit/HEAD", CommitHash ++ "\n", !IO),
        write_text_file(".minigit/index", "", !IO),
        io.write_string("Committed " ++ CommitHash ++ "\n", !IO)
    ).

%-----------------------------------------------------------------------------%
% status

:- pred cmd_status(io::di, io::uo) is det.
cmd_status(!IO) :-
    read_text_file(".minigit/index", IndexStr, !IO),
    Lines = string.split_at_char('\n', IndexStr),
    list.filter_map(parse_index_line, Lines, Entries),
    io.write_string("Staged files:\n", !IO),
    ( Entries = [] ->
        io.write_string("(none)\n", !IO)
    ;
        list.foldl(print_staged_file, Entries, !IO)
    ).

:- pred print_staged_file(pair(string, string)::in, io::di, io::uo) is det.
print_staged_file(F - _, !IO) :-
    io.write_string(F ++ "\n", !IO).

%-----------------------------------------------------------------------------%
% log

:- pred cmd_log(io::di, io::uo) is det.
cmd_log(!IO) :-
    read_text_file(".minigit/HEAD", HeadStr, !IO),
    Hash = string.strip(HeadStr),
    ( Hash = "" ->
        io.write_string("No commits\n", !IO)
    ;
        print_log(Hash, !IO)
    ).

:- pred print_log(string::in, io::di, io::uo) is det.
print_log(Hash, !IO) :-
    CommitPath = ".minigit/commits/" ++ Hash,
    io.check_file_accessibility(CommitPath, [read], Res, !IO),
    ( Res = ok ->
        read_text_file(CommitPath, Content, !IO),
        CLines = string.split_at_char('\n', Content),
        ( CLines = [ParentLine, TimestampLine, MsgLine | _] ->
            Parent    = value_after_colon(ParentLine),
            Timestamp = value_after_colon(TimestampLine),
            Message   = value_after_colon(MsgLine),
            io.write_string("commit " ++ Hash ++ "\n", !IO),
            io.write_string("Date: " ++ Timestamp ++ "\n", !IO),
            io.write_string("Message: " ++ Message ++ "\n", !IO),
            io.write_string("\n", !IO),
            ( Parent = "NONE" ->
                true
            ;
                print_log(Parent, !IO)
            )
        ;
            true
        )
    ;
        true
    ).

%-----------------------------------------------------------------------------%
% diff

:- type commit_result
    --->    commit_ok(list(pair(string, string)))
    ;       commit_error.

:- pred cmd_diff(string::in, string::in, io::di, io::uo) is det.
cmd_diff(C1, C2, !IO) :-
    read_commit_files(C1, Res1, !IO),
    ( Res1 = commit_error ->
        io.write_string("Invalid commit\n", !IO),
        io.set_exit_status(1, !IO)
    ; Res1 = commit_ok(Files1) ->
        read_commit_files(C2, Res2, !IO),
        ( Res2 = commit_error ->
            io.write_string("Invalid commit\n", !IO),
            io.set_exit_status(1, !IO)
        ; Res2 = commit_ok(Files2) ->
            list.foldl(check_added(Files1), Files2, !IO),
            list.foldl(check_removed(Files2), Files1, !IO),
            list.foldl(check_modified(Files2), Files1, !IO)
        ;
            true
        )
    ;
        true
    ).

:- pred read_commit_files(string::in, commit_result::out, io::di, io::uo) is det.
read_commit_files(Hash, Result, !IO) :-
    Path = ".minigit/commits/" ++ Hash,
    io.check_file_accessibility(Path, [read], Res, !IO),
    ( Res = ok ->
        read_text_file(Path, Content, !IO),
        parse_commit_files(Content, Files),
        Result = commit_ok(Files)
    ;
        Result = commit_error
    ).

:- pred parse_commit_files(string::in, list(pair(string, string))::out) is det.
parse_commit_files(Content, Files) :-
    Lines = string.split_at_char('\n', Content),
    skip_to_files(Lines, FileLines),
    list.filter_map(parse_index_line, FileLines, Files).

:- pred skip_to_files(list(string)::in, list(string)::out) is det.
skip_to_files([], []).
skip_to_files([H | T], Result) :-
    ( H = "files:" ->
        Result = T
    ;
        skip_to_files(T, Result)
    ).

:- pred file_in_list(string::in, list(pair(string, string))::in) is semidet.
file_in_list(F, [First | Rest]) :-
    ( First = F - _ ->
        true
    ;
        file_in_list(F, Rest)
    ).

:- pred find_file_hash(string::in, list(pair(string, string))::in, string::out) is semidet.
find_file_hash(F, [First | Rest], H) :-
    ( First = F - FirstH ->
        H = FirstH
    ;
        find_file_hash(F, Rest, H)
    ).

:- pred check_added(list(pair(string, string))::in, pair(string, string)::in,
    io::di, io::uo) is det.
check_added(Files1, F2 - _, !IO) :-
    ( file_in_list(F2, Files1) ->
        true
    ;
        io.write_string("Added: " ++ F2 ++ "\n", !IO)
    ).

:- pred check_removed(list(pair(string, string))::in, pair(string, string)::in,
    io::di, io::uo) is det.
check_removed(Files2, F1 - _, !IO) :-
    ( file_in_list(F1, Files2) ->
        true
    ;
        io.write_string("Removed: " ++ F1 ++ "\n", !IO)
    ).

:- pred check_modified(list(pair(string, string))::in, pair(string, string)::in,
    io::di, io::uo) is det.
check_modified(Files2, F1 - H1, !IO) :-
    ( find_file_hash(F1, Files2, H2) ->
        ( H1 = H2 ->
            true
        ;
            io.write_string("Modified: " ++ F1 ++ "\n", !IO)
        )
    ;
        true
    ).

%-----------------------------------------------------------------------------%
% checkout

:- pred cmd_checkout(string::in, io::di, io::uo) is det.
cmd_checkout(Hash, !IO) :-
    Path = ".minigit/commits/" ++ Hash,
    io.check_file_accessibility(Path, [read], Res, !IO),
    ( Res = ok ->
        read_text_file(Path, Content, !IO),
        parse_commit_files(Content, Files),
        list.foldl(restore_file, Files, !IO),
        write_text_file(".minigit/HEAD", Hash ++ "\n", !IO),
        write_text_file(".minigit/index", "", !IO),
        io.write_string("Checked out " ++ Hash ++ "\n", !IO)
    ;
        io.write_string("Invalid commit\n", !IO),
        io.set_exit_status(1, !IO)
    ).

:- pred restore_file(pair(string, string)::in, io::di, io::uo) is det.
restore_file(FileName - BlobHash, !IO) :-
    BlobPath = ".minigit/objects/" ++ BlobHash,
    read_text_file(BlobPath, Content, !IO),
    write_text_file(FileName, Content, !IO).

%-----------------------------------------------------------------------------%
% reset

:- pred cmd_reset(string::in, io::di, io::uo) is det.
cmd_reset(Hash, !IO) :-
    Path = ".minigit/commits/" ++ Hash,
    io.check_file_accessibility(Path, [read], Res, !IO),
    ( Res = ok ->
        write_text_file(".minigit/HEAD", Hash ++ "\n", !IO),
        write_text_file(".minigit/index", "", !IO),
        io.write_string("Reset to " ++ Hash ++ "\n", !IO)
    ;
        io.write_string("Invalid commit\n", !IO),
        io.set_exit_status(1, !IO)
    ).

%-----------------------------------------------------------------------------%
% rm

:- pred cmd_rm(string::in, io::di, io::uo) is det.
cmd_rm(File, !IO) :-
    read_text_file(".minigit/index", IndexStr, !IO),
    Lines = string.split_at_char('\n', IndexStr),
    list.filter_map(parse_index_line, Lines, Entries),
    list.filter(entry_has_file(File), Entries, Found),
    ( Found = [] ->
        io.write_string("File not in index\n", !IO),
        io.set_exit_status(1, !IO)
    ;
        list.filter(entry_not_file(File), Entries, NewEntries),
        write_index(NewEntries, !IO)
    ).

:- pred entry_not_file(string::in, pair(string, string)::in) is semidet.
entry_not_file(Target, F - _) :-
    F \= Target.

%-----------------------------------------------------------------------------%
% show

:- pred cmd_show(string::in, io::di, io::uo) is det.
cmd_show(Hash, !IO) :-
    Path = ".minigit/commits/" ++ Hash,
    io.check_file_accessibility(Path, [read], Res, !IO),
    ( Res = ok ->
        read_text_file(Path, Content, !IO),
        CLines = string.split_at_char('\n', Content),
        ( CLines = [_, TimestampLine, MsgLine | _] ->
            Timestamp = value_after_colon(TimestampLine),
            Message   = value_after_colon(MsgLine),
            io.write_string("commit " ++ Hash ++ "\n", !IO),
            io.write_string("Date: " ++ Timestamp ++ "\n", !IO),
            io.write_string("Message: " ++ Message ++ "\n", !IO),
            io.write_string("Files:\n", !IO),
            parse_commit_files(Content, Files),
            list.sort(Files, SortedFiles),
            list.foldl(print_show_file, SortedFiles, !IO)
        ;
            true
        )
    ;
        io.write_string("Invalid commit\n", !IO),
        io.set_exit_status(1, !IO)
    ).

:- pred print_show_file(pair(string, string)::in, io::di, io::uo) is det.
print_show_file(F - H, !IO) :-
    io.write_string("  " ++ F ++ " " ++ H ++ "\n", !IO).

%-----------------------------------------------------------------------------%
% Hash (MiniHash: FNV-1a variant)

:- func compute_hash(string) = string.
compute_hash(S) = minihash(list.map(char.to_int, string.to_char_list(S))).

:- func minihash(list(int)) = string.
minihash(Bytes) = Hash :-
    H0 = uint64.det_from_int(1469598103934665603),
    list.foldl(minihash_step, Bytes, H0, H),
    Hash = uint64_to_hex16(H).

:- pred minihash_step(int::in, uint64::in, uint64::out) is det.
minihash_step(B, H0, H2) :-
    FNVPrime = uint64.det_from_int(1099511628211),
    BU = uint64.cast_from_int(B),
    H1 = uint64.xor(H0, BU),
    H2 = H1 * FNVPrime.

:- func uint64_to_hex16(uint64) = string.
uint64_to_hex16(H) = S :-
    Mask = uint64.det_from_int(15),
    Nibbles = list.map(
        func(Shift) = uint64.cast_to_int((H >> Shift) /\ Mask),
        [60, 56, 52, 48, 44, 40, 36, 32, 28, 24, 20, 16, 12, 8, 4, 0]),
    Chars = list.map(nibble_to_char, Nibbles),
    S = string.from_char_list(Chars).

:- func nibble_to_char(int) = char.
nibble_to_char(N) = C :-
    ( N < 10 ->
        C = char.det_from_int(char.to_int('0') + N)
    ;
        C = char.det_from_int(char.to_int('a') + N - 10)
    ).

%-----------------------------------------------------------------------------%
% File I/O helpers

:- pred read_text_file(string::in, string::out, io::di, io::uo) is det.
read_text_file(Path, Content, !IO) :-
    io.open_input(Path, OpenRes, !IO),
    ( OpenRes = ok(Stream) ->
        io.read_file_as_string(Stream, ReadRes, !IO),
        io.close_input(Stream, !IO),
        ( ReadRes = ok(C) ->
            Content = C
        ;
            Content = ""
        )
    ;
        Content = ""
    ).

:- pred write_text_file(string::in, string::in, io::di, io::uo) is det.
write_text_file(Path, Content, !IO) :-
    io.open_output(Path, OpenRes, !IO),
    ( OpenRes = ok(Stream) ->
        io.write_string(Stream, Content, !IO),
        io.close_output(Stream, !IO)
    ;
        true
    ).

%-----------------------------------------------------------------------------%
% Index helpers

:- pred parse_index_line(string::in, pair(string, string)::out) is semidet.
parse_index_line(Line, F - H) :-
    Line \= "",
    Words = string.split_at_char(' ', Line),
    Words = [F, H | _].

:- pred entry_has_file(string::in, pair(string, string)::in) is semidet.
entry_has_file(F, F - _).

:- func update_entry(string, string, pair(string, string)) = pair(string, string).
update_entry(TargetF, NewH, F - OldH) = Result :-
    ( F = TargetF ->
        Result = F - NewH
    ;
        Result = F - OldH
    ).

:- pred write_index(list(pair(string, string))::in, io::di, io::uo) is det.
write_index(Entries, !IO) :-
    Lines = list.map(func(F - H) = F ++ " " ++ H, Entries),
    ( Lines = [] ->
        Content = ""
    ;
        Content = string.join_list("\n", Lines) ++ "\n"
    ),
    write_text_file(".minigit/index", Content, !IO).

%-----------------------------------------------------------------------------%
% String helpers

:- func value_after_colon(string) = string.
value_after_colon(Line) = Value :-
    ( string.sub_string_search(Line, ": ", Pos) ->
        Start = Pos + 2,
        Value = string.between(Line, Start, string.length(Line))
    ;
        Value = ""
    ).
