program minigit
  use iso_fortran_env, only: int64
  implicit none

  integer :: nargs
  character(len=512) :: cmd, arg2, arg3

  nargs = command_argument_count()
  if (nargs == 0) then
    write(*,'(a)') 'Usage: minigit <command>'
    stop 1
  end if

  call get_command_argument(1, cmd)
  cmd = trim(adjustl(cmd))

  if (cmd == 'init') then
    call cmd_init()
  else if (cmd == 'add') then
    if (nargs < 2) then
      write(*,'(a)') 'File not found'
      stop 1
    end if
    call get_command_argument(2, arg2)
    call cmd_add(trim(adjustl(arg2)))
  else if (cmd == 'commit') then
    if (nargs < 3) then
      write(*,'(a)') 'Nothing to commit'
      stop 1
    end if
    call get_command_argument(2, arg2)
    call get_command_argument(3, arg3)
    call cmd_commit(trim(adjustl(arg3)))
  else if (cmd == 'status') then
    call cmd_status()
  else if (cmd == 'log') then
    call cmd_log()
  else if (cmd == 'diff') then
    if (nargs < 3) then
      write(*,'(a)') 'Invalid commit'
      stop 1
    end if
    call get_command_argument(2, arg2)
    call get_command_argument(3, arg3)
    call cmd_diff(trim(adjustl(arg2)), trim(adjustl(arg3)))
  else if (cmd == 'checkout') then
    if (nargs < 2) then
      write(*,'(a)') 'Invalid commit'
      stop 1
    end if
    call get_command_argument(2, arg2)
    call cmd_checkout(trim(adjustl(arg2)))
  else if (cmd == 'reset') then
    if (nargs < 2) then
      write(*,'(a)') 'Invalid commit'
      stop 1
    end if
    call get_command_argument(2, arg2)
    call cmd_reset(trim(adjustl(arg2)))
  else if (cmd == 'rm') then
    if (nargs < 2) then
      write(*,'(a)') 'File not in index'
      stop 1
    end if
    call get_command_argument(2, arg2)
    call cmd_rm(trim(adjustl(arg2)))
  else if (cmd == 'show') then
    if (nargs < 2) then
      write(*,'(a)') 'Invalid commit'
      stop 1
    end if
    call get_command_argument(2, arg2)
    call cmd_show(trim(adjustl(arg2)))
  else
    write(*,'(a)') 'Unknown command: ' // trim(cmd)
    stop 1
  end if

contains

  !============================================================
  ! MiniHash: FNV-1a variant
  ! h_init = 1469598103934665603
  ! for each byte b: h = (h XOR b) * 1099511628211  mod 2^64
  !============================================================

  subroutine int64_to_hex16(val, str)
    integer(int64), intent(in)  :: val
    character(len=16), intent(out) :: str
    character(len=16), parameter :: HEX = '0123456789abcdef'
    integer(int64) :: tmp, nibble
    integer :: i

    tmp = val
    do i = 16, 1, -1
      nibble = iand(tmp, 15_int64)
      if (nibble < 0_int64) nibble = nibble + 16_int64
      str(i:i) = HEX(int(nibble)+1 : int(nibble)+1)
      tmp = ishft(tmp, -4)
    end do
  end subroutine int64_to_hex16

  function minihash_file(filename) result(hash_str)
    character(len=*), intent(in) :: filename
    character(len=16) :: hash_str
    integer(int64) :: h
    integer(int64), parameter :: HINIT = 1469598103934665603_int64
    integer(int64), parameter :: PRIME = 1099511628211_int64
    integer :: ios, u
    character(len=1) :: byte
    integer(int64) :: b

    h = HINIT
    open(newunit=u, file=filename, access='stream', form='unformatted', &
         status='old', iostat=ios)
    if (ios /= 0) then
      hash_str = '????????????????'
      return
    end if
    do
      read(u, iostat=ios) byte
      if (ios /= 0) exit
      b = ichar(byte, int64)
      h = ieor(h, b)
      h = h * PRIME
    end do
    close(u)
    call int64_to_hex16(h, hash_str)
  end function minihash_file

  function minihash_buf(buf, n) result(hash_str)
    character(len=*), intent(in) :: buf
    integer, intent(in) :: n
    character(len=16) :: hash_str
    integer(int64) :: h
    integer(int64), parameter :: HINIT = 1469598103934665603_int64
    integer(int64), parameter :: PRIME = 1099511628211_int64
    integer :: i
    integer(int64) :: b

    h = HINIT
    do i = 1, n
      b = ichar(buf(i:i), int64)
      h = ieor(h, b)
      h = h * PRIME
    end do
    call int64_to_hex16(h, hash_str)
  end function minihash_buf

  !============================================================
  ! cmd_init
  !============================================================
  subroutine cmd_init()
    logical :: exists
    integer :: ios, u

    inquire(file='.minigit/HEAD', exist=exists)
    if (exists) then
      write(*,'(a)') 'Repository already initialized'
      return
    end if

    call execute_command_line('mkdir -p .minigit/objects .minigit/commits', wait=.true.)

    open(newunit=u, file='.minigit/HEAD', status='replace', iostat=ios)
    close(u)

    open(newunit=u, file='.minigit/index', status='replace', iostat=ios)
    close(u)

    write(*,'(a)') 'Initialized empty repository'
  end subroutine cmd_init

  !============================================================
  ! cmd_add
  !============================================================
  subroutine cmd_add(filename)
    character(len=*), intent(in) :: filename
    character(len=16) :: hash_str
    logical :: exists
    integer, parameter :: MAX_FILES = 256
    character(len=512) :: idx_names(MAX_FILES)
    character(len=16)  :: idx_hashes(MAX_FILES)
    integer :: nidx, i
    logical :: found

    inquire(file=filename, exist=exists)
    if (.not. exists) then
      write(*,'(a)') 'File not found'
      stop 1
    end if

    hash_str = minihash_file(filename)

    call copy_file(filename, '.minigit/objects/' // trim(hash_str))

    call read_index(idx_names, idx_hashes, nidx)

    found = .false.
    do i = 1, nidx
      if (trim(idx_names(i)) == trim(filename)) then
        idx_hashes(i) = hash_str
        found = .true.
        exit
      end if
    end do

    if (.not. found) then
      nidx = nidx + 1
      idx_names(nidx) = filename
      idx_hashes(nidx) = hash_str
    end if

    call write_index(idx_names, idx_hashes, nidx)
  end subroutine cmd_add

  !============================================================
  ! cmd_commit
  !============================================================
  subroutine cmd_commit(message)
    character(len=*), intent(in) :: message
    integer, parameter :: MAX_FILES = 256
    character(len=512) :: idx_names(MAX_FILES)
    character(len=16)  :: idx_hashes(MAX_FILES)
    integer :: nidx, i, u, ios
    character(len=16) :: parent_hash, commit_hash
    character(len=32) :: timestamp_str
    integer(int64) :: epoch
    character(len=65536) :: content
    integer :: clen

    call read_index(idx_names, idx_hashes, nidx)

    if (nidx == 0) then
      write(*,'(a)') 'Nothing to commit'
      stop 1
    end if

    call sort_string_pairs(idx_names, idx_hashes, nidx)

    call read_head(parent_hash)
    if (len_trim(parent_hash) == 0) parent_hash = 'NONE'

    epoch = get_unix_time()
    write(timestamp_str, '(i20)') epoch
    timestamp_str = adjustl(timestamp_str)

    clen = 0
    call buf_append(content, clen, 'parent: ' // trim(parent_hash) // char(10))
    call buf_append(content, clen, 'timestamp: ' // trim(timestamp_str) // char(10))
    call buf_append(content, clen, 'message: ' // trim(message) // char(10))
    call buf_append(content, clen, 'files:' // char(10))
    do i = 1, nidx
      call buf_append(content, clen, &
        trim(idx_names(i)) // ' ' // trim(idx_hashes(i)) // char(10))
    end do

    commit_hash = minihash_buf(content, clen)

    open(newunit=u, file='.minigit/commits/' // trim(commit_hash), &
         access='stream', form='unformatted', status='replace', iostat=ios)
    write(u) content(1:clen)
    close(u)

    call write_head(commit_hash)
    call clear_index()

    write(*,'(a)') 'Committed ' // trim(commit_hash)
  end subroutine cmd_commit

  !============================================================
  ! cmd_status
  !============================================================
  subroutine cmd_status()
    integer, parameter :: MAX_FILES = 256
    character(len=512) :: idx_names(MAX_FILES)
    character(len=16)  :: idx_hashes(MAX_FILES)
    integer :: nidx, i

    call read_index(idx_names, idx_hashes, nidx)

    write(*,'(a)') 'Staged files:'
    if (nidx == 0) then
      write(*,'(a)') '(none)'
    else
      do i = 1, nidx
        write(*,'(a)') trim(idx_names(i))
      end do
    end if
  end subroutine cmd_status

  !============================================================
  ! cmd_log
  !============================================================
  subroutine cmd_log()
    character(len=16)   :: current_hash
    character(len=1024) :: commit_path
    character(len=4096) :: line
    character(len=16)   :: parent_hash
    character(len=64)   :: timestamp_str
    character(len=1024) :: msg_str
    integer :: u, ios
    logical :: exists, first

    call read_head(current_hash)

    if (len_trim(current_hash) == 0) then
      write(*,'(a)') 'No commits'
      return
    end if

    first = .true.
    do while (len_trim(current_hash) > 0)
      commit_path = '.minigit/commits/' // trim(current_hash)
      inquire(file=trim(commit_path), exist=exists)
      if (.not. exists) exit

      open(newunit=u, file=trim(commit_path), status='old', iostat=ios)
      if (ios /= 0) exit

      parent_hash    = 'NONE'
      timestamp_str  = ''
      msg_str        = ''

      do
        read(u, '(a)', iostat=ios) line
        if (ios /= 0) exit
        line = trim(line)
        if (line(1:8) == 'parent: ') then
          parent_hash = trim(line(9:))
        else if (line(1:11) == 'timestamp: ') then
          timestamp_str = trim(line(12:))
        else if (line(1:9) == 'message: ') then
          msg_str = trim(line(10:))
        end if
      end do
      close(u)

      if (.not. first) write(*,'(a)') ''
      write(*,'(a)') 'commit ' // trim(current_hash)
      write(*,'(a)') 'Date: ' // trim(timestamp_str)
      write(*,'(a)') 'Message: ' // trim(msg_str)
      first = .false.

      if (trim(parent_hash) == 'NONE') then
        current_hash = ''
      else
        current_hash = trim(parent_hash)
      end if
    end do
  end subroutine cmd_log

  !============================================================
  ! cmd_diff
  !============================================================
  subroutine cmd_diff(hash1, hash2)
    character(len=*), intent(in) :: hash1, hash2
    integer, parameter :: MAX_FILES = 256
    character(len=512) :: fnames1(MAX_FILES), fnames2(MAX_FILES)
    character(len=16)  :: fhashes1(MAX_FILES), fhashes2(MAX_FILES)
    integer :: n1, n2, i, j
    character(len=64)  :: ts1, ts2, msg1, msg2
    character(len=16)  :: par1, par2
    logical :: ok1, ok2, found

    call read_commit(hash1, par1, ts1, msg1, fnames1, fhashes1, n1, ok1)
    if (.not. ok1) then
      write(*,'(a)') 'Invalid commit'
      stop 1
    end if

    call read_commit(hash2, par2, ts2, msg2, fnames2, fhashes2, n2, ok2)
    if (.not. ok2) then
      write(*,'(a)') 'Invalid commit'
      stop 1
    end if

    ! Added or Modified: files in commit2
    do i = 1, n2
      found = .false.
      do j = 1, n1
        if (trim(fnames2(i)) == trim(fnames1(j))) then
          found = .true.
          if (trim(fhashes2(i)) /= trim(fhashes1(j))) then
            write(*,'(a)') 'Modified: ' // trim(fnames2(i))
          end if
          exit
        end if
      end do
      if (.not. found) then
        write(*,'(a)') 'Added: ' // trim(fnames2(i))
      end if
    end do

    ! Removed: files in commit1 not in commit2
    do i = 1, n1
      found = .false.
      do j = 1, n2
        if (trim(fnames1(i)) == trim(fnames2(j))) then
          found = .true.
          exit
        end if
      end do
      if (.not. found) then
        write(*,'(a)') 'Removed: ' // trim(fnames1(i))
      end if
    end do
  end subroutine cmd_diff

  !============================================================
  ! cmd_checkout
  !============================================================
  subroutine cmd_checkout(hash)
    character(len=*), intent(in) :: hash
    integer, parameter :: MAX_FILES = 256
    character(len=512) :: fnames(MAX_FILES)
    character(len=16)  :: fhashes(MAX_FILES)
    integer :: nfiles, i
    character(len=16)  :: par
    character(len=64)  :: ts, msg
    logical :: ok

    call read_commit(hash, par, ts, msg, fnames, fhashes, nfiles, ok)
    if (.not. ok) then
      write(*,'(a)') 'Invalid commit'
      stop 1
    end if

    do i = 1, nfiles
      call copy_file('.minigit/objects/' // trim(fhashes(i)), trim(fnames(i)))
    end do

    call write_head(hash)
    call clear_index()

    write(*,'(a)') 'Checked out ' // trim(hash)
  end subroutine cmd_checkout

  !============================================================
  ! cmd_reset
  !============================================================
  subroutine cmd_reset(hash)
    character(len=*), intent(in) :: hash
    integer, parameter :: MAX_FILES = 256
    character(len=512) :: fnames(MAX_FILES)
    character(len=16)  :: fhashes(MAX_FILES)
    integer :: nfiles
    character(len=16)  :: par
    character(len=64)  :: ts, msg
    logical :: ok

    call read_commit(hash, par, ts, msg, fnames, fhashes, nfiles, ok)
    if (.not. ok) then
      write(*,'(a)') 'Invalid commit'
      stop 1
    end if

    call write_head(hash)
    call clear_index()

    write(*,'(a)') 'Reset to ' // trim(hash)
  end subroutine cmd_reset

  !============================================================
  ! cmd_rm
  !============================================================
  subroutine cmd_rm(filename)
    character(len=*), intent(in) :: filename
    integer, parameter :: MAX_FILES = 256
    character(len=512) :: idx_names(MAX_FILES)
    character(len=16)  :: idx_hashes(MAX_FILES)
    character(len=512) :: new_names(MAX_FILES)
    character(len=16)  :: new_hashes(MAX_FILES)
    integer :: nidx, nnew, i
    logical :: found

    call read_index(idx_names, idx_hashes, nidx)

    found = .false.
    nnew = 0
    do i = 1, nidx
      if (trim(idx_names(i)) == trim(filename)) then
        found = .true.
      else
        nnew = nnew + 1
        new_names(nnew) = idx_names(i)
        new_hashes(nnew) = idx_hashes(i)
      end if
    end do

    if (.not. found) then
      write(*,'(a)') 'File not in index'
      stop 1
    end if

    call write_index(new_names, new_hashes, nnew)
  end subroutine cmd_rm

  !============================================================
  ! cmd_show
  !============================================================
  subroutine cmd_show(hash)
    character(len=*), intent(in) :: hash
    integer, parameter :: MAX_FILES = 256
    character(len=512) :: fnames(MAX_FILES)
    character(len=16)  :: fhashes(MAX_FILES)
    integer :: nfiles, i
    character(len=16)  :: par
    character(len=64)  :: ts, msg
    logical :: ok

    call read_commit(hash, par, ts, msg, fnames, fhashes, nfiles, ok)
    if (.not. ok) then
      write(*,'(a)') 'Invalid commit'
      stop 1
    end if

    write(*,'(a)') 'commit ' // trim(hash)
    write(*,'(a)') 'Date: ' // trim(ts)
    write(*,'(a)') 'Message: ' // trim(msg)
    write(*,'(a)') 'Files:'
    do i = 1, nfiles
      write(*,'(a)') '  ' // trim(fnames(i)) // ' ' // trim(fhashes(i))
    end do
  end subroutine cmd_show

  !============================================================
  ! Helper: read_commit
  !============================================================
  subroutine read_commit(hash, parent_hash, timestamp_str, msg_str, &
                          fnames, fhashes, nfiles, ok)
    character(len=*), intent(in) :: hash
    character(len=16), intent(out) :: parent_hash
    character(len=64), intent(out) :: timestamp_str
    character(len=64), intent(out) :: msg_str
    integer, parameter :: MAX_FILES = 256
    character(len=512), intent(out) :: fnames(MAX_FILES)
    character(len=16),  intent(out) :: fhashes(MAX_FILES)
    integer, intent(out) :: nfiles
    logical, intent(out) :: ok

    character(len=1024) :: commit_path, line
    integer :: u, ios, sp
    logical :: exists, in_files

    ok = .false.
    nfiles = 0
    parent_hash = 'NONE'
    timestamp_str = ''
    msg_str = ''

    commit_path = '.minigit/commits/' // trim(hash)
    inquire(file=trim(commit_path), exist=exists)
    if (.not. exists) return

    open(newunit=u, file=trim(commit_path), status='old', iostat=ios)
    if (ios /= 0) return

    ok = .true.
    in_files = .false.

    do
      read(u, '(a)', iostat=ios) line
      if (ios /= 0) exit
      line = trim(line)
      if (in_files) then
        if (len_trim(line) == 0) cycle
        sp = index(line, ' ')
        if (sp > 0 .and. nfiles < MAX_FILES) then
          nfiles = nfiles + 1
          fnames(nfiles)  = line(1:sp-1)
          fhashes(nfiles) = trim(line(sp+1:))
        end if
      else if (line(1:8) == 'parent: ') then
        parent_hash = trim(line(9:))
      else if (line(1:11) == 'timestamp: ') then
        timestamp_str = trim(line(12:))
      else if (line(1:9) == 'message: ') then
        msg_str = trim(line(10:))
      else if (trim(line) == 'files:') then
        in_files = .true.
      end if
    end do
    close(u)
  end subroutine read_commit

  !============================================================
  ! Helpers: HEAD
  !============================================================
  subroutine read_head(hash)
    character(len=16), intent(out) :: hash
    integer :: u, ios

    hash = ''
    open(newunit=u, file='.minigit/HEAD', status='old', iostat=ios)
    if (ios /= 0) return
    read(u, '(a)', iostat=ios) hash
    close(u)
    hash = trim(adjustl(hash))
  end subroutine read_head

  subroutine write_head(hash)
    character(len=*), intent(in) :: hash
    integer :: u, ios

    open(newunit=u, file='.minigit/HEAD', status='replace', iostat=ios)
    write(u, '(a)') trim(hash)
    close(u)
  end subroutine write_head

  !============================================================
  ! Helpers: index
  !============================================================
  subroutine read_index(names, hashes, n)
    character(len=512), intent(out) :: names(*)
    character(len=16),  intent(out) :: hashes(*)
    integer, intent(out) :: n
    integer :: u, ios, sp
    character(len=1024) :: line

    n = 0
    open(newunit=u, file='.minigit/index', status='old', iostat=ios)
    if (ios /= 0) return
    do
      read(u, '(a)', iostat=ios) line
      if (ios /= 0) exit
      line = trim(line)
      if (len_trim(line) == 0) cycle
      sp = index(line, ' ')
      if (sp > 0) then
        n = n + 1
        names(n)  = line(1:sp-1)
        hashes(n) = trim(line(sp+1:))
      end if
    end do
    close(u)
  end subroutine read_index

  subroutine write_index(names, hashes, n)
    character(len=512), intent(in) :: names(*)
    character(len=16),  intent(in) :: hashes(*)
    integer, intent(in) :: n
    integer :: u, ios, i

    open(newunit=u, file='.minigit/index', status='replace', iostat=ios)
    do i = 1, n
      write(u, '(a)') trim(names(i)) // ' ' // trim(hashes(i))
    end do
    close(u)
  end subroutine write_index

  subroutine clear_index()
    integer :: u, ios

    open(newunit=u, file='.minigit/index', status='replace', iostat=ios)
    close(u)
  end subroutine clear_index

  !============================================================
  ! Helper: copy file byte-by-byte
  !============================================================
  subroutine copy_file(src, dst)
    character(len=*), intent(in) :: src, dst
    integer :: su, du, ios
    character(len=1) :: byte

    open(newunit=su, file=src, access='stream', form='unformatted', &
         status='old', iostat=ios)
    if (ios /= 0) return

    open(newunit=du, file=dst, access='stream', form='unformatted', &
         status='replace', iostat=ios)
    if (ios /= 0) then
      close(su)
      return
    end if

    do
      read(su, iostat=ios) byte
      if (ios /= 0) exit
      write(du) byte
    end do

    close(su)
    close(du)
  end subroutine copy_file

  !============================================================
  ! Helper: insertion sort (filenames + parallel hash array)
  !============================================================
  subroutine sort_string_pairs(names, hashes, n)
    character(len=512), intent(inout) :: names(n)
    character(len=16),  intent(inout) :: hashes(n)
    integer, intent(in) :: n
    integer :: i, j
    character(len=512) :: tn
    character(len=16)  :: th

    do i = 2, n
      tn = names(i)
      th = hashes(i)
      j = i - 1
      do while (j >= 1 .and. trim(names(j)) > trim(tn))
        names(j+1)  = names(j)
        hashes(j+1) = hashes(j)
        j = j - 1
      end do
      names(j+1)  = tn
      hashes(j+1) = th
    end do
  end subroutine sort_string_pairs

  !============================================================
  ! Helper: append s to buf, advancing pos
  !============================================================
  subroutine buf_append(buf, pos, s)
    character(len=*), intent(inout) :: buf
    integer, intent(inout) :: pos
    character(len=*), intent(in) :: s
    integer :: slen

    slen = len(s)
    if (slen > 0) then
      buf(pos+1 : pos+slen) = s
      pos = pos + slen
    end if
  end subroutine buf_append

  !============================================================
  ! Helper: Unix timestamp via date_and_time
  !============================================================
  function get_unix_time() result(epoch)
    integer(int64) :: epoch
    integer, dimension(8) :: v
    integer(int64) :: year, month, day, hour, minute, second, utc_min
    integer(int64) :: days, y, m
    integer(int64), dimension(12) :: mdays

    call date_and_time(values=v)
    year    = int(v(1), int64)
    month   = int(v(2), int64)
    day     = int(v(3), int64)
    utc_min = int(v(4), int64)
    hour    = int(v(5), int64)
    minute  = int(v(6), int64)
    second  = int(v(7), int64)

    mdays = [31_int64, 28_int64, 31_int64, 30_int64, 31_int64, 30_int64, &
             31_int64, 31_int64, 30_int64, 31_int64, 30_int64, 31_int64]

    ! Days from 1970-01-01 to start of current year
    days = 0_int64
    do y = 1970_int64, year - 1_int64
      if (is_leap(y)) then
        days = days + 366_int64
      else
        days = days + 365_int64
      end if
    end do

    ! Days from start of year to start of current month
    do m = 1_int64, month - 1_int64
      days = days + mdays(int(m))
      if (m == 2_int64 .and. is_leap(year)) days = days + 1_int64
    end do

    days = days + day - 1_int64

    epoch = days * 86400_int64 &
          + hour * 3600_int64 &
          + minute * 60_int64 &
          + second &
          - utc_min * 60_int64
  end function get_unix_time

  function is_leap(y) result(leap)
    integer(int64), intent(in) :: y
    logical :: leap

    leap = (mod(y, 4_int64) == 0_int64 .and. mod(y, 100_int64) /= 0_int64) &
        .or. (mod(y, 400_int64) == 0_int64)
  end function is_leap

end program minigit
