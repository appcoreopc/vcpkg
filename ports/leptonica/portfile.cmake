include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DanBloomberg/leptonica
    REF 1.76.0
    SHA512 0d7575dc38d1e656a228ef30412a2cbb908b9c7c8636e4e96f4a7dc0429c04709316b8ad04893285ab430c1b2063d71537fc5b989a0f9dbdbec488713e1bab1f
    HEAD_REF master
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/fix-cmakelists.patch
        ${CMAKE_CURRENT_LIST_DIR}/use-tiff-libraries.patch
        ${CMAKE_CURRENT_LIST_DIR}/find-dependency.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSTATIC=${STATIC}
        -DCMAKE_REQUIRED_INCLUDES=${CURRENT_INSTALLED_DIR}/include # for check_include_file()
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "cmake")

# Fix relative paths that vcpkg_fixup_cmake_targets didn't pick up
set(TARGETS_CMAKE ${CURRENT_PACKAGES_DIR}/share/leptonica/LeptonicaTargets.cmake)
file(READ ${TARGETS_CMAKE} _contents)
string(REGEX REPLACE
    "get_filename_component\\(_IMPORT_PREFIX \"\\\${CMAKE_CURRENT_LIST_FILE}\" PATH\\)(\nget_filename_component\\(_IMPORT_PREFIX \"\\\${_IMPORT_PREFIX}\" PATH\\))*"
    "get_filename_component(_IMPORT_PREFIX \"\${CMAKE_CURRENT_LIST_FILE}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)"
    _contents "${_contents}")
file(WRITE ${TARGETS_CMAKE} "${_contents}")


vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)

# Handle copyright
file(COPY ${SOURCE_PATH}/leptonica-license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/leptonica)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/leptonica/leptonica-license.txt ${CURRENT_PACKAGES_DIR}/share/leptonica/copyright)
