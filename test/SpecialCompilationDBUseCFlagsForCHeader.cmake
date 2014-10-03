# /tests/ClangTidySpecialCompilationDBUseCXXFlagsForCPPHeader.cmake
# Add some sources and defines to a custom target
# One of them is a C++ header. The CMAKE_C_FLAGS
# should be part of its compile commands.
#
# See LICENCE.md for Copyright information

include (${POLYSQUARE_TOOLING_CMAKE_DIRECTORY}/PolysquareToolingUtil.cmake)
include (${POLYSQUARE_TOOLING_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

set (HEADER_FILE ${CMAKE_CURRENT_BINARY_DIR}/Header.h)
set (C_SOURCE_FILE ${CMAKE_CURRENT_BINARY_DIR}/Source.c)
set (HEADER_FILE_CONTENTS
     "#ifndef HEADER_H\n"
     "#define HEADER_H\n"
     "extern const int i\;\n"
     "#endif")
set (C_SOURCE_FILE_CONTENTS
     "#include <Header.h>\n"
     "const int i = 1\;\n"
     "int main (void)\n"
     "{\n"
     "    return 0\;\n"
     "}\n")
set (TARGET target)

file (WRITE ${HEADER_FILE} ${HEADER_FILE_CONTENTS})
file (WRITE ${C_SOURCE_FILE} ${C_SOURCE_FILE_CONTENTS})

set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DUSING_CXX_DEFINE")
set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DUSING_C_DEFINE")

add_custom_target (${TARGET} ALL
                   SOURCES
                   ${C_SOURCE_FILE}
                   ${HEADER_FILE})
psq_make_compilation_db (${TARGET}
                         COMPILATION_DB_DIR
                         C_SOURCES ${C_SOURCE_FILE} ${HEADER_FILE}
                         INTERNAL_INCLUDE_DIRS
                         ${CMAKE_CURRENT_BINARY_DIR})

set (COMPILE_COMMANDS
     ${COMPILATION_DB_DIR}/compile_commands.json)
assert_file_has_line_matching (${COMPILE_COMMANDS}
                               "^.*Header.h.*-DUSING_C_DEFINE.*$")