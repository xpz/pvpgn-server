# put in this file everything that needs to be setup depending
# on the target architecture

# our own modules
set(CMAKE_MODULE_PATH
  ${CMAKE_SOURCE_DIR}/cmake/Modules
)

# include used modules
include(DefineInstallationPaths)
include(CheckIncludeFileCXX)
include(CheckFunctionExists)
include(CheckSymbolExists)
include(CheckTypeSize)
include(CheckLibraryExists)
include(CheckCXXCompilerFlag)
include(CheckCXXSourceCompiles)
include(CheckMkdirArgs)

# setup short variable path names
set(BINDIR ${BIN_INSTALL_DIR})
set(SBINDIR ${SBIN_INSTALL_DIR})
set(SYSCONFDIR ${SYSCONF_INSTALL_DIR})
set(LOCALSTATEDIR ${LOCALSTATE_INSTALL_DIR})
set(MANDIR ${MAN_INSTALL_DIR})

# set default hardcoded config paths
if(WIN32)
	set(BNETD_DEFAULT_CONF_FILE "conf/bnetd.conf")
	set(D2CS_DEFAULT_CONF_FILE "conf/d2cs.conf")
	set(D2DBS_DEFAULT_CONF_FILE "conf/d2dbs.conf")
else(WIN32)
	set(BNETD_DEFAULT_CONF_FILE "${SYSCONFDIR}/bnetd.conf")
	set(D2CS_DEFAULT_CONF_FILE "${SYSCONFDIR}/d2cs.conf")
	set(D2DBS_DEFAULT_CONF_FILE "${SYSCONFDIR}/d2dbs.conf")
endif(WIN32)

enable_language(C)
# library checks
find_package(ZLIB REQUIRED)
check_library_exists(nsl gethostbyname "" HAVE_LIBNSL)
check_library_exists(socket socket "" HAVE_LIBSOCKET)
check_library_exists(resolv inet_aton "" HAVE_LIBRESOLV)
check_library_exists(bind __inet_aton "" HAVE_LIBBIND)

if(WITH_LUA)
    find_package(Lua REQUIRED)
endif(WITH_LUA)

# storage module checks
if(WITH_ODBC)
    find_package(ODBC REQUIRED)
endif(WITH_ODBC)
if(WITH_MYSQL)
    find_package(MySQL REQUIRED)
endif(WITH_MYSQL)
if(WITH_SQLITE3)
    find_package(SQLite3 REQUIRED)
endif(WITH_SQLITE3)
if(WITH_PGSQL)
    find_package(PostgreSQL REQUIRED)
endif(WITH_PGSQL)

# if any of nsl or socket exists we need to make sure the following tests
# use them otherwise some functions may not be found
if(HAVE_LIBNSL)
	SET(CMAKE_REQUIRED_LIBRARIES ${CMAKE_REQUIRED_LIBRARIES} nsl)
	SET(NETWORK_LIBRARIES ${NETWORK_LIBRARIES} nsl)
endif(HAVE_LIBNSL)
if(HAVE_LIBSOCKET)
	SET(CMAKE_REQUIRED_LIBRARIES ${CMAKE_REQUIRED_LIBRARIES} socket)
	SET(NETWORK_LIBRARIES ${NETWORK_LIBRARIES} socket)
endif(HAVE_LIBSOCKET)
if(HAVE_LIBRESOLV)
	SET(CMAKE_REQUIRED_LIBRARIES ${CMAKE_REQUIRED_LIBRARIES} resolv)
	SET(NETWORK_LIBRARIES ${NETWORK_LIBRARIES} resolv)
endif(HAVE_LIBRESOLV)
if(HAVE_LIBBIND)
	# this is used for BeOS BONE, when someone will want
	# to test pvpgn with cmake on BeOS please contact us
	SET(CMAKE_REQUIRED_LIBRARIES ${CMAKE_REQUIRED_LIBRARIES} bind)
	SET(NETWORK_LIBRARIES ${NETWORK_LIBRARIES} bind)
endif(HAVE_LIBBIND)

# for win32 unconditionally add network library linking to "ws2_32"
if(WIN32)
	SET(NETWORK_LIBRARIES ${NETWORK_LIBRARIES} ws2_32)
endif(WIN32)


message(STATUS "Checking POSIX headers")
check_include_file_cxx(arpa/inet.h HAVE_ARPA_INET_H)
check_include_file_cxx(dirent.h HAVE_DIRENT_H)
check_include_file_cxx(grp.h HAVE_GRP_H)
check_include_file_cxx(fcntl.h HAVE_FCNTL_H)
check_include_file_cxx(netdb.h HAVE_NETDB_H)
check_include_file_cxx(netinet/in.h HAVE_NETINET_IN_H)
check_include_file_cxx(poll.h HAVE_POLL_H)
check_include_file_cxx(pwd.h HAVE_PWD_H)
check_include_file_cxx(sys/mman.h HAVE_SYS_MMAN_H)
check_include_file_cxx(sys/resource.h HAVE_SYS_RESOURCE_H)
check_include_file_cxx(sys/select.h HAVE_SYS_SELECT_H)
check_include_file_cxx(sys/socket.h HAVE_SYS_SOCKET_H)
check_include_file_cxx(sys/stat.h HAVE_SYS_STAT_H)
check_include_file_cxx(sys/time.h HAVE_SYS_TIME_H)
check_include_file_cxx(sys/types.h HAVE_SYS_TYPES_H)
check_include_file_cxx(sys/utsname.h HAVE_SYS_UTSNAME_H)
check_include_file_cxx(sys/wait.h HAVE_SYS_WAIT_H)
check_include_file_cxx(termios.h HAVE_TERMIOS_H)
check_include_file_cxx(unistd.h HAVE_UNISTD_H)

message(STATUS "Checking optional POSIX/required SUS headers")
check_include_file_cxx(sys/timeb.h HAVE_SYS_TIMEB_H)

message(STATUS "Checking FreeBSD-based headers")
if (HAVE_SYS_TYPES_H)
check_include_file_cxx(sys/event.h HAVE_SYS_EVENT_H)
endif()
check_include_file_cxx(sys/param.h HAVE_SYS_PARAM_H)

message(STATUS "Checking BSD headers")
check_include_file_cxx(sys/file.h HAVE_SYS_FILE_H)

message(STATUS "Checking Linux headers")
check_include_file_cxx(sys/epoll.h HAVE_SYS_EPOLL_H)

message(STATUS "Checking Win32 headers")
check_include_file_cxx(windows.h HAVE_WINDOWS_H)
check_include_file_cxx(winsock2.h HAVE_WINSOCK2_H)
check_include_file_cxx(ws2tcpip.h HAVE_WS2TCPIP_H)
check_include_file_cxx(process.h HAVE_PROCESS_H)

message(STATUS "Checking other headers")
check_include_file_cxx(dir.h HAVE_DIR_H)
check_include_file_cxx(direct.h HAVE_DIRECT_H)
check_include_file_cxx(ndir.h HAVE_NDIR_H)
check_include_file_cxx(sys/dir.h HAVE_SYS_DIR_H)
check_include_file_cxx(sys/ndir.h HAVE_SYS_NDIR_H)
check_include_file_cxx(sys/poll.h HAVE_SYS_POLL_H)
#Keep for now
check_include_file_cxx(stdint.h HAVE_STDINT_H)

check_type_size("unsigned char" SIZEOF_UNSIGNED_CHAR)
check_type_size("unsigned short" SIZEOF_UNSIGNED_SHORT)
check_type_size("unsigned int" SIZEOF_UNSIGNED_INT)
check_type_size("unsigned long" SIZEOF_UNSIGNED_LONG)
check_type_size("unsigned long long" SIZEOF_UNSIGNED_LONG_LONG)
check_type_size("signed char" SIZEOF_SIGNED_CHAR)
check_type_size("signed short" SIZEOF_SIGNED_SHORT)
check_type_size("signed int" SIZEOF_SIGNED_INT)
check_type_size("signed long" SIZEOF_SIGNED_LONG)
check_type_size("signed long long" SIZEOF_SIGNED_LONG_LONG)

check_function_exists(chdir HAVE_CHDIR)
check_function_exists(epoll_create HAVE_EPOLL_CREATE)
check_function_exists(fork HAVE_FORK)
check_function_exists(ftime HAVE_FTIME)
check_function_exists(getgid HAVE_GETGID)
check_function_exists(getgrnam HAVE_GETGRNAM)
check_function_exists(getlogin HAVE_GETLOGIN)
check_function_exists(getopt HAVE_GETOPT)
check_function_exists(getpid HAVE_GETPID)
check_function_exists(getpwnam HAVE_GETPWNAME)
check_function_exists(getrlimit HAVE_GETRLIMIT)
check_function_exists(gettimeofday HAVE_GETTIMEOFDAY)
check_function_exists(getuid HAVE_GETUID)
check_function_exists(ioctl HAVE_IOCTL)
check_function_exists(kqueue HAVE_KQUEUE)
check_function_exists(_mkdir HAVE__MKDIR)
check_function_exists(mkdir HAVE_MKDIR)
check_function_exists(mmap HAVE_MMAP)
check_function_exists(pipe HAVE_PIPE)
check_function_exists(poll HAVE_POLL)
check_function_exists(setitimer HAVE_SETITIMER)
check_function_exists(setpgid HAVE_SETPGID)
check_function_exists(setpgrp HAVE_SETPGRP)
check_function_exists(setsid HAVE_SETSID)
check_function_exists(setuid HAVE_SETUID)
check_function_exists(sigaction HAVE_SIGACTION)
check_function_exists(sigaddset HAVE_SIGADDSET)
check_function_exists(sigprocmask HAVE_SIGPROCMASK)
check_function_exists(strcasecmp HAVE_STRCASECMP)
check_function_exists(strdup HAVE_STRDUP)
check_function_exists(stricmp HAVE_STRICMP)
check_function_exists(strncasecmp HAVE_STRNCASECMP)
check_function_exists(strnicmp HAVE_STRNICMP)
check_function_exists(strsep HAVE_STRSEP)
check_function_exists(uname HAVE_UNAME)
check_function_exists(wait HAVE_WAIT)
check_function_exists(waitpid HAVE_WAITPID)

CHECK_CXX_SOURCE_COMPILES(
"
#include <memory>
int main() {
	auto foo = std::make_unique<int>(1);
	return 0;
}
" HAVE_MAKE_UNIQUE)


# winsock2.h and ws2_32 should provide these
if(HAVE_WINSOCK2_H)
	set(HAVE_GETHOSTNAME ON)
	set(HAVE_SELECT ON)
	set(HAVE_SOCKET ON)
	set(HAVE_RECV ON)
	set(HAVE_SEND ON)
	set(HAVE_RECVFROM ON)
	set(HAVE_SENDTO ON)
	set(HAVE_GETHOSTBYNAME ON)
	set(HAVE_GETSERVBYNAME ON)
else(HAVE_WINSOCK2_H)
	check_function_exists(gethostname HAVE_GETHOSTNAME)
	check_function_exists(select HAVE_SELECT)
	check_function_exists(socket HAVE_SOCKET)
	check_function_exists(recv HAVE_RECV)
	check_function_exists(send HAVE_SEND)
	check_function_exists(recvfrom HAVE_RECVFROM)
	check_function_exists(sendto HAVE_SENDTO)
	check_function_exists(gethostbyname HAVE_GETHOSTBYNAME)
	check_function_exists(getservbyname HAVE_GETSERVBYNAME)
endif(HAVE_WINSOCK2_H)

check_mkdir_args(MKDIR_TAKES_ONE_ARG)

configure_file(config.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config.h)

# new VS.Net deprecates with warnings most of ISO C functions without this
if(MSVC)
    add_definitions(-D_CRT_SECURE_NO_DEPRECATE -D_CRT_NONSTDC_NO_DEPRECATE)
endif(MSVC)
