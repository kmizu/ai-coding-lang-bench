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

end program minigit
