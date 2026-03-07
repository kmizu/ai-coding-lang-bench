program minigit
  use iso_fortran_env, only: int64, int8
  implicit none

  integer :: nargs
  character(len=4096) :: cmd

  nargs = command_argument_count()
  if (nargs == 0) then
    write(*,'(a)') 'Usage: minigit <command>'
    stop 1
  end if

  call get_command_argument(1, cmd)

  select case(trim(cmd))
  case('init')
    call cmd_init()
  case('add')
    call cmd_add()
  case('commit')
    call cmd_commit()
  case('log')
    call cmd_log()
  case('status')
    call cmd_status()
  case('diff')
    call cmd_diff()
  case('checkout')
    call cmd_checkout()
  case('reset')
    call cmd_reset()
  case('rm')
    call cmd_rm()
  case('show')
    call cmd_show()
  case default
    write(*,'(a,a)') 'Unknown command: ', trim(cmd)
    stop 1
  end select

contains

  !============================================================
  ! MiniHash: FNV-1a variant, 64-bit
  ! init: h = 1469598103934665603
  ! per byte b: h ^= b; h = (h * 1099511628211) mod 2^64
  !============================================================

  function minihash_bytes(data, n) result(h)
    integer(int8), intent(in) :: data(:)
    integer,        intent(in) :: n
    integer(int64) :: h
    integer        :: i
    integer(int64) :: b

    h = 1469598103934665603_int64
    do i = 1, n
      b = iand(int(data(i), int64), 255_int64)
      h = ieor(h, b)
      h = h * 1099511628211_int64   ! wraps mod 2^64 via two's-complement overflow
    end do
  end function

  function minihash_str(s, n) result(h)
    character(len=*), intent(in) :: s
    integer,          intent(in) :: n
    integer(int64) :: h
    integer        :: i

    h = 1469598103934665603_int64
    do i = 1, n
      h = ieor(h, int(iachar(s(i:i)), int64))
      h = h * 1099511628211_int64
    end do
  end function

  subroutine hash_to_hex(h, hex_str)
    integer(int64),    intent(in)  :: h
    character(len=16), intent(out) :: hex_str
    integer(int64) :: tmp
    integer        :: i, nibble
    character(len=16), parameter :: HEX = '0123456789abcdef'

    tmp = h
    do i = 16, 1, -1
      nibble = int(iand(tmp, 15_int64)) + 1
      hex_str(i:i) = HEX(nibble:nibble)
      tmp = ishft(tmp, -4)   ! logical right shift, zero-fills from left
    end do
  end subroutine

  function get_unix_time() result(t)
    use iso_c_binding, only: c_long, c_ptr, c_null_ptr
    integer(int64) :: t
    interface
      function c_time(tp) bind(c, name='time') result(r)
        use iso_c_binding, only: c_long, c_ptr
        type(c_ptr), value :: tp
        integer(c_long)    :: r
      end function
    end interface
    t = int(c_time(c_null_ptr), int64)
  end function

  subroutine str_append(buf, pos, s)
    character(len=*), intent(inout) :: buf
    integer,          intent(inout) :: pos
    character(len=*), intent(in)    :: s
    integer :: n
    n = len(s)
    if (n > 0 .and. pos + n <= len(buf)) then
      buf(pos+1:pos+n) = s
      pos = pos + n
    end if
  end subroutine

  !============================================================
  ! Commands
  !============================================================

  subroutine cmd_init()
    logical :: exists
    integer :: ios

    ! Check if repo already exists by looking for HEAD
    inquire(file='.minigit/HEAD', exist=exists)
    if (exists) then
      write(*,'(a)') 'Repository already initialized'
      stop 0
    end if

    call execute_command_line('mkdir -p .minigit/objects .minigit/commits', wait=.true.)

    open(unit=10, file='.minigit/index', status='replace', action='write', iostat=ios)
    close(10)
    open(unit=10, file='.minigit/HEAD',  status='replace', action='write', iostat=ios)
    close(10)
  end subroutine

  subroutine get_file_hash(filename, hash_str)
    character(len=*),  intent(in)  :: filename
    character(len=16), intent(out) :: hash_str
    integer(int8), allocatable :: data(:)
    integer(int64) :: h
    integer        :: ios, n

    open(unit=20, file=trim(filename), access='stream', form='unformatted', &
         action='read', status='old', iostat=ios)
    if (ios /= 0) then
      hash_str = '0000000000000000'
      return
    end if
    inquire(unit=20, size=n)
    allocate(data(max(1, n)))
    data = 0_int8
    if (n > 0) read(20, iostat=ios) data(1:n)
    close(20)

    h = minihash_bytes(data, n)
    call hash_to_hex(h, hash_str)
    deallocate(data)
  end subroutine

  subroutine cmd_add()
    character(len=4096) :: filename, obj_path, line
    integer(int8), allocatable :: data(:)
    integer(int64) :: h
    character(len=16) :: hash_str
    logical :: exists, already_staged
    integer :: ios, n

    if (command_argument_count() < 2) then
      write(*,'(a)') 'Usage: minigit add <file>'
      stop 1
    end if

    call get_command_argument(2, filename)
    filename = trim(filename)

    inquire(file=trim(filename), exist=exists)
    if (.not. exists) then
      write(*,'(a)') 'File not found'
      stop 1
    end if

    ! Read file as raw bytes via stream access
    open(unit=20, file=trim(filename), access='stream', form='unformatted', &
         action='read', status='old', iostat=ios)
    if (ios /= 0) then
      write(*,'(a)') 'File not found'
      stop 1
    end if
    inquire(unit=20, size=n)
    allocate(data(max(1, n)))
    data = 0_int8
    if (n > 0) read(20, iostat=ios) data(1:n)
    close(20)

    ! Compute MiniHash
    h = minihash_bytes(data, n)
    call hash_to_hex(h, hash_str)

    ! Store blob if not already present
    obj_path = '.minigit/objects/' // trim(hash_str)
    inquire(file=trim(obj_path), exist=exists)
    if (.not. exists) then
      open(unit=21, file=trim(obj_path), access='stream', form='unformatted', &
           action='write', status='new', iostat=ios)
      if (n > 0) write(21) data(1:n)
      close(21)
    end if

    deallocate(data)

    ! Add filename to index if not already staged
    already_staged = .false.
    open(unit=22, file='.minigit/index', action='read', status='old', iostat=ios)
    if (ios == 0) then
      do
        read(22, '(a)', iostat=ios) line
        if (ios /= 0) exit
        if (trim(line) == trim(filename)) then
          already_staged = .true.
          exit
        end if
      end do
      close(22)
    end if

    if (.not. already_staged) then
      open(unit=23, file='.minigit/index', position='append', &
           action='write', status='old', iostat=ios)
      write(23, '(a)') trim(filename)
      close(23)
    end if
  end subroutine

  subroutine cmd_commit()
    character(len=4096) :: msg_flag, msg, line, head_content
    character(len=4096), allocatable :: filenames(:)
    character(len=16),   allocatable :: hashes(:)
    character(len=4096) :: tmp_fname
    character(len=16)   :: tmp_hash, parent_hash, commit_hash
    integer(int64)      :: epoch_time, h
    character(len=32)   :: ts_str
    integer, parameter  :: BUFSIZE = 1048576
    character(len=BUFSIZE) :: content
    integer :: clen, ios, n_files, i, j

    if (command_argument_count() < 3) then
      write(*,'(a)') 'Usage: minigit commit -m <message>'
      stop 1
    end if

    call get_command_argument(2, msg_flag)
    call get_command_argument(3, msg)

    if (trim(msg_flag) /= '-m') then
      write(*,'(a)') 'Usage: minigit commit -m <message>'
      stop 1
    end if

    ! Count non-empty lines in index
    n_files = 0
    open(unit=10, file='.minigit/index', action='read', status='old', iostat=ios)
    if (ios == 0) then
      do
        read(10, '(a)', iostat=ios) line
        if (ios /= 0) exit
        if (len_trim(line) > 0) n_files = n_files + 1
      end do
      close(10)
    end if

    if (n_files == 0) then
      write(*,'(a)') 'Nothing to commit'
      stop 1
    end if

    ! Read filenames from index
    allocate(filenames(n_files))
    allocate(hashes(n_files))

    open(unit=10, file='.minigit/index', action='read', status='old')
    i = 0
    do
      read(10, '(a)', iostat=ios) line
      if (ios /= 0) exit
      if (len_trim(line) > 0) then
        i = i + 1
        filenames(i) = trim(line)
      end if
    end do
    close(10)

    ! Compute blob hash for each file
    do i = 1, n_files
      call get_file_hash(trim(filenames(i)), hashes(i))
    end do

    ! Lexicographic sort (bubble sort)
    do i = 1, n_files - 1
      do j = i + 1, n_files
        if (trim(filenames(i)) > trim(filenames(j))) then
          tmp_fname    = filenames(i)
          filenames(i) = filenames(j)
          filenames(j) = tmp_fname
          tmp_hash  = hashes(i)
          hashes(i) = hashes(j)
          hashes(j) = tmp_hash
        end if
      end do
    end do

    ! Read parent hash from HEAD (NONE if no prior commits)
    parent_hash = 'NONE'
    open(unit=11, file='.minigit/HEAD', action='read', status='old', iostat=ios)
    if (ios == 0) then
      read(11, '(a)', iostat=ios) head_content
      close(11)
      if (ios == 0 .and. len_trim(head_content) > 0) then
        parent_hash = trim(head_content)
      end if
    end if

    ! Unix timestamp
    epoch_time = get_unix_time()
    write(ts_str, '(i0)') epoch_time

    ! Build commit content string with LF line endings (char(10))
    content = ''
    clen    = 0
    call str_append(content, clen, 'parent: '    // trim(parent_hash) // char(10))
    call str_append(content, clen, 'timestamp: ' // trim(ts_str)      // char(10))
    call str_append(content, clen, 'message: '   // trim(msg)         // char(10))
    call str_append(content, clen, 'files:'                            // char(10))
    do i = 1, n_files
      call str_append(content, clen, &
        trim(filenames(i)) // ' ' // trim(hashes(i)) // char(10))
    end do

    ! Commit hash = MiniHash of the full commit content
    h = minihash_str(content, clen)
    call hash_to_hex(h, commit_hash)

    ! Write commit file line-by-line (gfortran on Linux writes LF, matching content)
    open(unit=12, file='.minigit/commits/' // trim(commit_hash), &
         action='write', status='new', iostat=ios)
    write(12, '(a)') 'parent: '    // trim(parent_hash)
    write(12, '(a)') 'timestamp: ' // trim(ts_str)
    write(12, '(a)') 'message: '   // trim(msg)
    write(12, '(a)') 'files:'
    do i = 1, n_files
      write(12, '(a)') trim(filenames(i)) // ' ' // trim(hashes(i))
    end do
    close(12)

    ! Update HEAD
    open(unit=13, file='.minigit/HEAD', action='write', status='replace')
    write(13, '(a)') trim(commit_hash)
    close(13)

    ! Clear index
    open(unit=14, file='.minigit/index', action='write', status='replace')
    close(14)

    write(*,'(a,a)') 'Committed ', trim(commit_hash)

    deallocate(filenames, hashes)
  end subroutine

  subroutine cmd_log()
    character(len=4096) :: current_hash, commit_path, line
    character(len=4096) :: parent_str, timestamp_str, msg_str
    logical :: exists
    integer :: ios

    ! Read HEAD
    open(unit=10, file='.minigit/HEAD', action='read', status='old', iostat=ios)
    if (ios /= 0) then
      write(*,'(a)') 'No commits'
      stop 0
    end if
    read(10, '(a)', iostat=ios) current_hash
    close(10)

    if (ios /= 0 .or. len_trim(current_hash) == 0) then
      write(*,'(a)') 'No commits'
      stop 0
    end if

    current_hash = trim(current_hash)

    do
      if (len_trim(current_hash) == 0) exit

      commit_path = '.minigit/commits/' // trim(current_hash)
      inquire(file=trim(commit_path), exist=exists)
      if (.not. exists) exit

      write(*,'(a,1x,a)') 'commit', trim(current_hash)

      parent_str    = ''
      timestamp_str = ''
      msg_str       = ''

      open(unit=11, file=trim(commit_path), action='read', status='old')
      do
        read(11, '(a)', iostat=ios) line
        if (ios /= 0) exit
        if (len_trim(line) >= 8  .and. line(1:8)  == 'parent: ')    &
          parent_str    = trim(line(9:))
        if (len_trim(line) >= 11 .and. line(1:11) == 'timestamp: ') &
          timestamp_str = trim(line(12:))
        if (len_trim(line) >= 9  .and. line(1:9)  == 'message: ')   &
          msg_str       = trim(line(10:))
      end do
      close(11)

      write(*,'(a,a)') 'Date: ',    trim(timestamp_str)
      write(*,'(a,a)') 'Message: ', trim(msg_str)
      write(*,'(a)')   ''

      if (trim(parent_str) == 'NONE' .or. len_trim(parent_str) == 0) exit
      current_hash = trim(parent_str)
    end do
  end subroutine

  subroutine cmd_status()
    character(len=4096) :: line
    integer :: ios, n_files

    ! Count staged files
    n_files = 0
    open(unit=10, file='.minigit/index', action='read', status='old', iostat=ios)
    if (ios == 0) then
      do
        read(10, '(a)', iostat=ios) line
        if (ios /= 0) exit
        if (len_trim(line) > 0) n_files = n_files + 1
      end do
      close(10)
    end if

    write(*,'(a)') 'Staged files:'
    if (n_files == 0) then
      write(*,'(a)') '(none)'
    else
      open(unit=10, file='.minigit/index', action='read', status='old', iostat=ios)
      do
        read(10, '(a)', iostat=ios) line
        if (ios /= 0) exit
        if (len_trim(line) > 0) write(*,'(a)') trim(line)
      end do
      close(10)
    end if
  end subroutine

  ! Parse files section from a commit file into parallel arrays.
  ! Returns number of files found.
  subroutine parse_commit_files(commit_path, filenames, file_hashes, n_files)
    character(len=*),               intent(in)  :: commit_path
    character(len=4096), allocatable, intent(out) :: filenames(:)
    character(len=16),   allocatable, intent(out) :: file_hashes(:)
    integer,                         intent(out) :: n_files
    character(len=4096) :: line
    integer :: ios, space_pos, count

    ! First pass: count files
    count = 0
    open(unit=30, file=trim(commit_path), action='read', status='old', iostat=ios)
    if (ios /= 0) then
      n_files = 0
      allocate(filenames(0), file_hashes(0))
      return
    end if
    ! skip until 'files:' line
    do
      read(30, '(a)', iostat=ios) line
      if (ios /= 0) exit
      if (trim(line) == 'files:') exit
    end do
    do
      read(30, '(a)', iostat=ios) line
      if (ios /= 0) exit
      if (len_trim(line) > 0) count = count + 1
    end do
    close(30)

    n_files = count
    allocate(filenames(count), file_hashes(count))

    ! Second pass: read file entries
    count = 0
    open(unit=30, file=trim(commit_path), action='read', status='old')
    do
      read(30, '(a)', iostat=ios) line
      if (ios /= 0) exit
      if (trim(line) == 'files:') exit
    end do
    do
      read(30, '(a)', iostat=ios) line
      if (ios /= 0) exit
      if (len_trim(line) > 0) then
        count = count + 1
        ! Find last space to split filename and hash
        space_pos = index(trim(line), ' ', back=.true.)
        if (space_pos > 0) then
          filenames(count)   = trim(line(1:space_pos-1))
          file_hashes(count) = trim(line(space_pos+1:))
        else
          filenames(count)   = trim(line)
          file_hashes(count) = '0000000000000000'
        end if
      end if
    end do
    close(30)
  end subroutine

  subroutine cmd_diff()
    character(len=4096) :: hash1, hash2, path1, path2
    character(len=4096), allocatable :: files1(:), files2(:)
    character(len=16),   allocatable :: hashes1(:), hashes2(:)
    integer :: n1, n2, i, j
    logical :: exists, found
    character(len=16) :: h1, h2

    if (command_argument_count() < 3) then
      write(*,'(a)') 'Usage: minigit diff <commit1> <commit2>'
      stop 1
    end if

    call get_command_argument(2, hash1)
    call get_command_argument(3, hash2)
    hash1 = trim(hash1)
    hash2 = trim(hash2)

    path1 = '.minigit/commits/' // trim(hash1)
    path2 = '.minigit/commits/' // trim(hash2)

    inquire(file=trim(path1), exist=exists)
    if (.not. exists) then
      write(*,'(a)') 'Invalid commit'
      stop 1
    end if
    inquire(file=trim(path2), exist=exists)
    if (.not. exists) then
      write(*,'(a)') 'Invalid commit'
      stop 1
    end if

    call parse_commit_files(path1, files1, hashes1, n1)
    call parse_commit_files(path2, files2, hashes2, n2)

    ! Files in commit2 not in commit1 -> Added
    ! Files in commit1 not in commit2 -> Removed
    ! Files in both but different hash -> Modified

    ! Added or Modified: iterate commit2 files
    do i = 1, n2
      found = .false.
      do j = 1, n1
        if (trim(files2(i)) == trim(files1(j))) then
          found = .true.
          h1 = trim(hashes1(j))
          h2 = trim(hashes2(i))
          if (h1 /= h2) then
            write(*,'(a,a)') 'Modified: ', trim(files2(i))
          end if
          exit
        end if
      end do
      if (.not. found) then
        write(*,'(a,a)') 'Added: ', trim(files2(i))
      end if
    end do

    ! Removed: in commit1 but not commit2
    do i = 1, n1
      found = .false.
      do j = 1, n2
        if (trim(files1(i)) == trim(files2(j))) then
          found = .true.
          exit
        end if
      end do
      if (.not. found) then
        write(*,'(a,a)') 'Removed: ', trim(files1(i))
      end if
    end do

    if (allocated(files1))  deallocate(files1)
    if (allocated(hashes1)) deallocate(hashes1)
    if (allocated(files2))  deallocate(files2)
    if (allocated(hashes2)) deallocate(hashes2)
  end subroutine

  subroutine cmd_checkout()
    character(len=4096) :: commit_hash, commit_path
    character(len=4096), allocatable :: filenames(:)
    character(len=16),   allocatable :: file_hashes(:)
    character(len=4096) :: obj_path
    integer(int8), allocatable :: blob(:)
    integer :: n_files, i, ios, blob_size
    logical :: exists

    if (command_argument_count() < 2) then
      write(*,'(a)') 'Usage: minigit checkout <commit_hash>'
      stop 1
    end if

    call get_command_argument(2, commit_hash)
    commit_hash = trim(commit_hash)
    commit_path = '.minigit/commits/' // trim(commit_hash)

    inquire(file=trim(commit_path), exist=exists)
    if (.not. exists) then
      write(*,'(a)') 'Invalid commit'
      stop 1
    end if

    call parse_commit_files(commit_path, filenames, file_hashes, n_files)

    ! Restore each file from blob
    do i = 1, n_files
      obj_path = '.minigit/objects/' // trim(file_hashes(i))
      open(unit=40, file=trim(obj_path), access='stream', form='unformatted', &
           action='read', status='old', iostat=ios)
      if (ios /= 0) cycle
      inquire(unit=40, size=blob_size)
      allocate(blob(max(1, blob_size)))
      blob = 0_int8
      if (blob_size > 0) read(40, iostat=ios) blob(1:blob_size)
      close(40)

      open(unit=41, file=trim(filenames(i)), access='stream', form='unformatted', &
           action='write', status='replace', iostat=ios)
      if (blob_size > 0) write(41) blob(1:blob_size)
      close(41)
      deallocate(blob)
    end do

    ! Update HEAD
    open(unit=42, file='.minigit/HEAD', action='write', status='replace')
    write(42, '(a)') trim(commit_hash)
    close(42)

    ! Clear index
    open(unit=43, file='.minigit/index', action='write', status='replace')
    close(43)

    write(*,'(a,a)') 'Checked out ', trim(commit_hash)

    if (allocated(filenames))   deallocate(filenames)
    if (allocated(file_hashes)) deallocate(file_hashes)
  end subroutine

  subroutine cmd_reset()
    character(len=4096) :: commit_hash, commit_path
    logical :: exists
    integer :: ios

    if (command_argument_count() < 2) then
      write(*,'(a)') 'Usage: minigit reset <commit_hash>'
      stop 1
    end if

    call get_command_argument(2, commit_hash)
    commit_hash = trim(commit_hash)
    commit_path = '.minigit/commits/' // trim(commit_hash)

    inquire(file=trim(commit_path), exist=exists)
    if (.not. exists) then
      write(*,'(a)') 'Invalid commit'
      stop 1
    end if

    ! Update HEAD (do NOT touch working directory)
    open(unit=50, file='.minigit/HEAD', action='write', status='replace')
    write(50, '(a)') trim(commit_hash)
    close(50)

    ! Clear index
    open(unit=51, file='.minigit/index', action='write', status='replace')
    close(51)

    write(*,'(a,a)') 'Reset to ', trim(commit_hash)
  end subroutine

  subroutine cmd_rm()
    character(len=4096) :: target, line
    character(len=4096), allocatable :: lines(:)
    integer :: ios, n_lines, i
    logical :: found

    if (command_argument_count() < 2) then
      write(*,'(a)') 'Usage: minigit rm <file>'
      stop 1
    end if

    call get_command_argument(2, target)
    target = trim(target)

    ! Read all index lines
    n_lines = 0
    open(unit=60, file='.minigit/index', action='read', status='old', iostat=ios)
    if (ios == 0) then
      do
        read(60, '(a)', iostat=ios) line
        if (ios /= 0) exit
        if (len_trim(line) > 0) n_lines = n_lines + 1
      end do
      close(60)
    end if

    allocate(lines(n_lines))
    found = .false.

    open(unit=60, file='.minigit/index', action='read', status='old', iostat=ios)
    if (ios == 0) then
      i = 0
      do
        read(60, '(a)', iostat=ios) line
        if (ios /= 0) exit
        if (len_trim(line) > 0) then
          i = i + 1
          lines(i) = trim(line)
          if (trim(line) == target) found = .true.
        end if
      end do
      close(60)
    end if

    if (.not. found) then
      write(*,'(a)') 'File not in index'
      deallocate(lines)
      stop 1
    end if

    ! Rewrite index without the target
    open(unit=61, file='.minigit/index', action='write', status='replace')
    do i = 1, n_lines
      if (trim(lines(i)) /= target) then
        write(61, '(a)') trim(lines(i))
      end if
    end do
    close(61)

    deallocate(lines)
  end subroutine

  subroutine cmd_show()
    character(len=4096) :: commit_hash, commit_path, line
    character(len=4096) :: timestamp_str, msg_str
    character(len=4096), allocatable :: filenames(:)
    character(len=16),   allocatable :: file_hashes(:)
    integer :: n_files, i, ios
    logical :: exists

    if (command_argument_count() < 2) then
      write(*,'(a)') 'Usage: minigit show <commit_hash>'
      stop 1
    end if

    call get_command_argument(2, commit_hash)
    commit_hash = trim(commit_hash)
    commit_path = '.minigit/commits/' // trim(commit_hash)

    inquire(file=trim(commit_path), exist=exists)
    if (.not. exists) then
      write(*,'(a)') 'Invalid commit'
      stop 1
    end if

    ! Read metadata
    timestamp_str = ''
    msg_str       = ''
    open(unit=70, file=trim(commit_path), action='read', status='old')
    do
      read(70, '(a)', iostat=ios) line
      if (ios /= 0) exit
      if (len_trim(line) >= 11 .and. line(1:11) == 'timestamp: ') &
        timestamp_str = trim(line(12:))
      if (len_trim(line) >= 9  .and. line(1:9)  == 'message: ')   &
        msg_str = trim(line(10:))
    end do
    close(70)

    write(*,'(a,a)') 'commit ', trim(commit_hash)
    write(*,'(a,a)') 'Date: ', trim(timestamp_str)
    write(*,'(a,a)') 'Message: ', trim(msg_str)
    write(*,'(a)')   'Files:'

    call parse_commit_files(commit_path, filenames, file_hashes, n_files)

    do i = 1, n_files
      write(*,'(a,a,a,a)') '  ', trim(filenames(i)), ' ', trim(file_hashes(i))
    end do

    if (allocated(filenames))   deallocate(filenames)
    if (allocated(file_hashes)) deallocate(file_hashes)
  end subroutine

end program minigit
