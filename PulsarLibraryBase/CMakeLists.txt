cmake_minimum_required(VERSION 3.1)
project(PulsarLibraryBase)
file(GLOB __PLB_FILES "${PLB_PREFIX}/cmake/*.cmake")
install(FILES ${__PLB_FILES}
        DESTINATION share/cmake/PulsarLibraryBase
)
configure_file("${PLB_PREFIX}/cmake/PulsarLibraryBaseConfig.cmake.in"
               PulsarLibraryBaseConfig.cmake @ONLY
)
install(FILES ${CMAKE_BINARY_DIR}/PulsarLibraryBaseConfig.cmake
        DESTINATION share/cmake/PulsarLibraryBase
)
