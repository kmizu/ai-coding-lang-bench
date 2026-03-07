program minigit
  use iso_fortran_env, only: int64
  implicit none

  integer :: nargs
  character(len=4096) :: cmd, a1, a2

  nargs = command_argument_count()
  if (nargs == 0) then
    write(*, '(A)') 'Usage: minigit <command>'
    stop 1
  end if

  call get_command_argument(1, cmd)

  select case(trim(cmd))
  case('init')
    call do_init()
  case('add')
    if (nargs < 2) then
      write(*, '(A)') 'Usage: minigit add <file>'
      stop 1
    end if
    call get_command_argument(2, a1)
    call do_add(trim(a1))
  case('commit')
    if (nargs < 3) then
      write(*, '(A)') 'Usage: minigit commit -m <message>'
      stop 1
    end if
    call get_command_argument(2, a1)
    call get_command_argument(3, a2)
    if (trim(a1) /= '-m') then
      write(*, '(A)') 'Usage: minigit commit -m <message>'
      stop 1
    end if
    call do_commit(trim(a2))
  case('status')
    call do_status()
  case('log')
    call do_log()
  case('diff')
    if (nargs < 3) then
      write(*, '(A)') 'Usage: minigit diff <commit1> <commit2>'
      stop 1
    end if
    call get_command_argument(2, a1)
    call get_command_argument(3, a2)
    call do_diff(trim(a1), trim(a2))
  case('checkout')
    if (nargs < 2) then
      write(*, '(A)') 'Usage: minigit checkout <commit_hash>'
      stop 1
    end if
    call get_command_argument(2, a1)
    call do_checkout(trim(a1))
  case('reset')
    if (nargs < 2) then
      write(*, '(A)') 'Usage: minigit reset <commit_hash>'
      stop 1
    end if
    call get_command_argument(2, a1)
    call do_reset(trim(a1))
  case('rm')
    if (nargs < 2) then
      write(*, '(A)') 'Usage: minigit rm <file>'
      stop 1
    end if
    call get_command_argument(2, a1)
    call do_rm(trim(a1))
  case('show')
    if (nargs < 2) then
      write(*, '(A)') 'Usage: minigit show <commit_hash>'
      stop 1
    end if
    call get_command_argument(2, a1)
    call do_show(trim(a1))
  case default
    write(*, '(A)') 'Unknown command: ' // trim(cmd)
    stop 1
  end select

contains

  ! Format int64 bit pattern as 16-char lowercase hex
  subroutine to_hex(h, hex)
    integer(int64), intent(in)  :: h
    character(len=16), intent(out) :: hex
    integer(int64) :: tmp, nibble
    integer :: i
    character(len=16), parameter :: DIGITS = '0123456789abcdef'
    tmp = h
    do i = 16, 1, -1
      nibble = iand(tmp, 15_int64)
      hex(i:i) = DIGITS(int(nibble)+1 : int(nibble)+1)
      tmp = ishft(tmp, -4)   ! logical right shift, zero-fills MSB
    end do
  end subroutine to_hex

  ! Compute MiniHash (FNV-1a variant) of a file; return 16-char lowercase hex
  function hash_file(fname) result(hex)
    character(len=*), intent(in) :: fname
    character(len=16) :: hex
    integer(int64) :: h, b, fsz, k
    character(len=1) :: ch
    integer :: ios

    h = 1469598103934665603_int64
    open(unit=90, file=trim(fname), status='old', access='stream', &
         form='unformatted', action='read', iostat=ios)
    if (ios /= 0) then
      hex = '0000000000000000'
      return
    end if
    inquire(unit=90, size=fsz)
    do k = 1, fsz
      read(90, iostat=ios) ch
      if (ios /= 0) exit
      b = iand(int(ichar(ch), int64), 255_int64)
      h = ieor(h, b)
      h = h * 1099511628211_int64   ! overflow wraps mod 2^64 (gfortran guarantee)
    end do
    close(90)
    call to_hex(h, hex)
  end function hash_file

  ! Get Unix epoch via shell
  function get_epoch() result(ts)
    integer(int64) :: ts
    integer :: ios
    ts = 0_int64
    call execute_command_line('date +%s > /tmp/.minigit_epoch', exitstat=ios)
    if (ios /= 0) return
    open(unit=91, file='/tmp/.minigit_epoch', status='old', action='read', iostat=ios)
    if (ios /= 0) return
    read(91, *, iostat=ios) ts
    close(91)
  end function get_epoch

  ! Binary file copy
  subroutine copy_file(src, dst)
    character(len=*), intent(in) :: src, dst
    character(len=1) :: ch
    integer(int64) :: fsz, k
    integer :: ios
    open(unit=92, file=trim(src), status='old', access='stream', &
         form='unformatted', action='read', iostat=ios)
    if (ios /= 0) return
    inquire(unit=92, size=fsz)
    open(unit=93, file=trim(dst), status='replace', access='stream', &
         form='unformatted', action='write')
    do k = 1, fsz
      read(92, iostat=ios) ch
      if (ios /= 0) exit
      write(93) ch
    end do
    close(92)
    close(93)
  end subroutine copy_file

  ! ---- commands ----

  subroutine do_init()
    logical :: ex
    integer :: ios
    inquire(file='.minigit/HEAD', exist=ex)
    if (ex) then
      write(*, '(A)') 'Repository already initialized'
      stop
    end if
    call execute_command_line('mkdir -p .minigit/objects .minigit/commits', exitstat=ios)
    open(unit=10, file='.minigit/index', status='replace', action='write')
    close(10)
    open(unit=10, file='.minigit/HEAD',  status='replace', action='write')
    close(10)
    write(*, '(A)') 'Initialized empty repository'
  end subroutine do_init

  subroutine do_add(fname)
    character(len=*), intent(in) :: fname
    logical :: ex
    character(len=16)   :: hval
    character(len=4096) :: lines(1000), line, stored
    integer :: ios, sp, n, i
    logical :: found

    inquire(file=trim(fname), exist=ex)
    if (.not. ex) then
      write(*, '(A)') 'File not found'
      stop 1
    end if

    hval = hash_file(trim(fname))
    call copy_file(trim(fname), '.minigit/objects/' // hval)

    ! Read entire index, check if filename already staged
    n = 0
    found = .false.
    open(unit=11, file='.minigit/index', status='old', action='read', iostat=ios)
    if (ios == 0) then
      do
        read(11, '(A)', iostat=ios) line
        if (ios /= 0) exit
        if (len_trim(line) == 0) cycle
        sp = index(line, ' ')
        if (sp > 1) then
          stored = line(1:sp-1)
        else
          stored = trim(line)
        end if
        n = n + 1
        if (trim(stored) == trim(fname)) then
          ! Update hash for this entry
          lines(n) = trim(fname) // ' ' // hval
          found = .true.
        else
          lines(n) = trim(line)
        end if
      end do
      close(11)
    end if

    if (found) then
      ! Rewrite index with updated entry
      open(unit=11, file='.minigit/index', status='replace', action='write')
      do i = 1, n
        write(11, '(A)') trim(lines(i))
      end do
      close(11)
    else
      ! Append new entry
      open(unit=11, file='.minigit/index', status='old', position='append', &
           action='write', iostat=ios)
      if (ios /= 0) &
        open(unit=11, file='.minigit/index', status='replace', action='write')
      write(11, '(A)') trim(fname) // ' ' // hval
      close(11)
    end if
  end subroutine do_add

  subroutine do_commit(msg)
    character(len=*), intent(in) :: msg
    character(len=4096) :: fnames(1000), tmp_fn
    character(len=16)   :: fhashes(1000), tmp_fh
    integer :: nf, ios, i, j, sp
    character(len=4096) :: line
    character(len=16)   :: parent, chash
    integer(int64) :: ts

    ! Read index
    nf = 0
    open(unit=12, file='.minigit/index', status='old', action='read', iostat=ios)
    if (ios == 0) then
      do
        read(12, '(A)', iostat=ios) line
        if (ios /= 0) exit
        if (len_trim(line) == 0) cycle
        nf = nf + 1
        sp = index(line, ' ')
        if (sp > 1) then
          fnames(nf)  = line(1:sp-1)
          fhashes(nf) = line(sp+1:sp+16)
        else
          fnames(nf)  = trim(line)
          fhashes(nf) = hash_file(trim(line))
        end if
      end do
      close(12)
    end if

    if (nf == 0) then
      write(*, '(A)') 'Nothing to commit'
      stop 1
    end if

    ! Sort filenames lexicographically (bubble sort)
    do i = 1, nf - 1
      do j = i + 1, nf
        if (trim(fnames(i)) > trim(fnames(j))) then
          tmp_fn = fnames(i);  fnames(i)  = fnames(j);  fnames(j)  = tmp_fn
          tmp_fh = fhashes(i); fhashes(i) = fhashes(j); fhashes(j) = tmp_fh
        end if
      end do
    end do

    ! Read parent hash from HEAD
    parent = 'NONE'
    open(unit=13, file='.minigit/HEAD', status='old', action='read', iostat=ios)
    if (ios == 0) then
      read(13, '(A)', iostat=ios) line
      close(13)
      if (ios == 0 .and. len_trim(line) == 16) parent = trim(line)
    end if

    ts = get_epoch()

    ! Write commit content to temp file
    open(unit=14, file='/tmp/.minigit_commit', status='replace', action='write')
    write(14, '(A)')      'parent: '    // trim(parent)
    write(14, '(A,I0)')   'timestamp: ', ts
    write(14, '(A)')      'message: '   // trim(msg)
    write(14, '(A)')      'files:'
    do i = 1, nf
      write(14, '(A)') trim(fnames(i)) // ' ' // fhashes(i)
    end do
    close(14)

    ! Commit hash = MiniHash of commit file content
    chash = hash_file('/tmp/.minigit_commit')

    ! Store commit file
    call copy_file('/tmp/.minigit_commit', '.minigit/commits/' // chash)

    ! Update HEAD
    open(unit=15, file='.minigit/HEAD', status='replace', action='write')
    write(15, '(A)') chash
    close(15)

    ! Clear index
    open(unit=16, file='.minigit/index', status='replace', action='write')
    close(16)

    write(*, '(A)') 'Committed ' // chash
  end subroutine do_commit

  subroutine do_status()
    character(len=4096) :: line
    integer :: ios, count, sp
    character(len=4096) :: fname

    count = 0
    write(*, '(A)') 'Staged files:'

    open(unit=30, file='.minigit/index', status='old', action='read', iostat=ios)
    if (ios == 0) then
      do
        read(30, '(A)', iostat=ios) line
        if (ios /= 0) exit
        if (len_trim(line) == 0) cycle
        sp = index(line, ' ')
        if (sp > 1) then
          fname = line(1:sp-1)
        else
          fname = trim(line)
        end if
        write(*, '(A)') trim(fname)
        count = count + 1
      end do
      close(30)
    end if

    if (count == 0) then
      write(*, '(A)') '(none)'
    end if
  end subroutine do_status

  subroutine do_log()
    character(len=16)   :: hash
    character(len=4096) :: line, par_v, ts_v, msg_v
    integer :: ios
    logical :: ex

    open(unit=20, file='.minigit/HEAD', status='old', action='read', iostat=ios)
    if (ios /= 0) then
      write(*, '(A)') 'No commits'
      return
    end if
    read(20, '(A)', iostat=ios) line
    close(20)

    if (ios /= 0 .or. len_trim(line) /= 16) then
      write(*, '(A)') 'No commits'
      return
    end if

    hash = trim(line)

    do
      inquire(file='.minigit/commits/' // hash, exist=ex)
      if (.not. ex) exit

      par_v = 'NONE'; ts_v = ''; msg_v = ''

      open(unit=21, file='.minigit/commits/' // hash, &
           status='old', action='read', iostat=ios)
      if (ios /= 0) exit
      do
        read(21, '(A)', iostat=ios) line
        if (ios /= 0) exit
        if (line(1:8)  == 'parent: ')    par_v = trim(line(9:))
        if (line(1:11) == 'timestamp: ') ts_v  = trim(line(12:))
        if (line(1:9)  == 'message: ')   msg_v = trim(line(10:))
      end do
      close(21)

      write(*, '(A)') 'commit '   // hash
      write(*, '(A)') 'Date: '    // trim(ts_v)
      write(*, '(A)') 'Message: ' // trim(msg_v)
      write(*, '(A)') ''

      if (trim(par_v) == 'NONE' .or. len_trim(par_v) /= 16) exit
      hash = trim(par_v)
    end do
  end subroutine do_log

  ! Parse a commit file: extract parent, timestamp, message, file list
  subroutine parse_commit(chash, par_v, ts_v, msg_v, fnames, fhashes, nf)
    character(len=*),    intent(in)  :: chash
    character(len=4096), intent(out) :: par_v, ts_v, msg_v
    character(len=4096), intent(out) :: fnames(1000)
    character(len=16),   intent(out) :: fhashes(1000)
    integer,             intent(out) :: nf
    character(len=4096) :: line
    integer :: ios, sp
    logical :: in_files

    par_v = 'NONE'; ts_v = ''; msg_v = ''
    nf = 0
    in_files = .false.

    open(unit=50, file='.minigit/commits/' // trim(chash), &
         status='old', action='read', iostat=ios)
    if (ios /= 0) return
    do
      read(50, '(A)', iostat=ios) line
      if (ios /= 0) exit
      if (in_files) then
        if (len_trim(line) == 0) cycle
        sp = index(line, ' ')
        if (sp > 1) then
          nf = nf + 1
          fnames(nf)  = line(1:sp-1)
          fhashes(nf) = line(sp+1:sp+16)
        end if
      else
        if (line(1:8)  == 'parent: ')    par_v = trim(line(9:))
        if (line(1:11) == 'timestamp: ') ts_v  = trim(line(12:))
        if (line(1:9)  == 'message: ')   msg_v = trim(line(10:))
        if (trim(line) == 'files:')      in_files = .true.
      end if
    end do
    close(50)
  end subroutine parse_commit

  subroutine do_diff(chash1, chash2)
    character(len=*), intent(in) :: chash1, chash2
    character(len=4096) :: par1, ts1, msg1, par2, ts2, msg2
    character(len=4096) :: fnames1(1000), fnames2(1000)
    character(len=16)   :: fhashes1(1000), fhashes2(1000)
    integer :: nf1, nf2, i, j
    logical :: ex1, ex2, found

    inquire(file='.minigit/commits/' // trim(chash1), exist=ex1)
    inquire(file='.minigit/commits/' // trim(chash2), exist=ex2)
    if (.not. ex1 .or. .not. ex2) then
      write(*, '(A)') 'Invalid commit'
      stop 1
    end if

    call parse_commit(trim(chash1), par1, ts1, msg1, fnames1, fhashes1, nf1)
    call parse_commit(trim(chash2), par2, ts2, msg2, fnames2, fhashes2, nf2)

    ! Files in commit2 but not in commit1 -> Added; in both with diff hash -> Modified
    do i = 1, nf2
      found = .false.
      do j = 1, nf1
        if (trim(fnames2(i)) == trim(fnames1(j))) then
          found = .true.
          if (trim(fhashes2(i)) /= trim(fhashes1(j))) then
            write(*, '(A)') 'Modified: ' // trim(fnames2(i))
          end if
          exit
        end if
      end do
      if (.not. found) then
        write(*, '(A)') 'Added: ' // trim(fnames2(i))
      end if
    end do

    ! Files in commit1 but not in commit2 -> Removed
    do i = 1, nf1
      found = .false.
      do j = 1, nf2
        if (trim(fnames1(i)) == trim(fnames2(j))) then
          found = .true.
          exit
        end if
      end do
      if (.not. found) then
        write(*, '(A)') 'Removed: ' // trim(fnames1(i))
      end if
    end do
  end subroutine do_diff

  subroutine do_checkout(chash)
    character(len=*), intent(in) :: chash
    logical :: ex
    character(len=4096) :: par_v, ts_v, msg_v
    character(len=4096) :: fnames(1000)
    character(len=16)   :: fhashes(1000)
    integer :: nf, i

    inquire(file='.minigit/commits/' // trim(chash), exist=ex)
    if (.not. ex) then
      write(*, '(A)') 'Invalid commit'
      stop 1
    end if

    call parse_commit(trim(chash), par_v, ts_v, msg_v, fnames, fhashes, nf)

    do i = 1, nf
      call copy_file('.minigit/objects/' // fhashes(i), trim(fnames(i)))
    end do

    open(unit=60, file='.minigit/HEAD', status='replace', action='write')
    write(60, '(A)') trim(chash)
    close(60)

    open(unit=61, file='.minigit/index', status='replace', action='write')
    close(61)

    write(*, '(A)') 'Checked out ' // trim(chash)
  end subroutine do_checkout

  subroutine do_reset(chash)
    character(len=*), intent(in) :: chash
    logical :: ex

    inquire(file='.minigit/commits/' // trim(chash), exist=ex)
    if (.not. ex) then
      write(*, '(A)') 'Invalid commit'
      stop 1
    end if

    open(unit=62, file='.minigit/HEAD', status='replace', action='write')
    write(62, '(A)') trim(chash)
    close(62)

    open(unit=63, file='.minigit/index', status='replace', action='write')
    close(63)

    write(*, '(A)') 'Reset to ' // trim(chash)
  end subroutine do_reset

  subroutine do_rm(fname)
    character(len=*), intent(in) :: fname
    character(len=4096) :: lines(1000), line, stored
    integer :: n, ios, i, sp
    logical :: found

    n = 0
    found = .false.

    open(unit=70, file='.minigit/index', status='old', action='read', iostat=ios)
    if (ios == 0) then
      do
        read(70, '(A)', iostat=ios) line
        if (ios /= 0) exit
        if (len_trim(line) == 0) cycle
        sp = index(line, ' ')
        if (sp > 1) then
          stored = line(1:sp-1)
        else
          stored = trim(line)
        end if
        if (trim(stored) == trim(fname)) then
          found = .true.
        else
          n = n + 1
          lines(n) = trim(line)
        end if
      end do
      close(70)
    end if

    if (.not. found) then
      write(*, '(A)') 'File not in index'
      stop 1
    end if

    open(unit=71, file='.minigit/index', status='replace', action='write')
    do i = 1, n
      write(71, '(A)') trim(lines(i))
    end do
    close(71)
  end subroutine do_rm

  subroutine do_show(chash)
    character(len=*), intent(in) :: chash
    logical :: ex
    character(len=4096) :: par_v, ts_v, msg_v
    character(len=4096) :: fnames(1000)
    character(len=16)   :: fhashes(1000)
    integer :: nf, i

    inquire(file='.minigit/commits/' // trim(chash), exist=ex)
    if (.not. ex) then
      write(*, '(A)') 'Invalid commit'
      stop 1
    end if

    call parse_commit(trim(chash), par_v, ts_v, msg_v, fnames, fhashes, nf)

    write(*, '(A)') 'commit ' // trim(chash)
    write(*, '(A)') 'Date: ' // trim(ts_v)
    write(*, '(A)') 'Message: ' // trim(msg_v)
    write(*, '(A)') 'Files:'
    do i = 1, nf
      write(*, '(A)') '  ' // trim(fnames(i)) // ' ' // fhashes(i)
    end do
  end subroutine do_show

end program minigit
