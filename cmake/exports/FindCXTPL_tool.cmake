################################################################################
# CXTPL_tool
################################################################################

# cached path to this file, forces refresh on each use
unset(FindCXTPL_tool_LIST_DIR CACHE)
set(FindCXTPL_tool_LIST_DIR "${CMAKE_CURRENT_LIST_DIR}"
  CACHE STRING "(autogenerated) path to FindCXTPL_tool.cmake")

# CXTPL_tool is enabled by default.
option(CXTPL_tool "Enable CXTPL_tool." ON)

if(CXTPL_tool)

    # Check if CXTPL_tool is installed with find_program.
    find_program(CXTPL_tool_PROGRAM CXTPL_tool
      HINTS
      ${CXTPL_tool_HINTS}
      ${CXTPL_tool_DIR}/build/bin/
      ${CXTPL_tool_PREFIX}/bin
      /usr/bin
      /usr/local/bin
      $PATH
      CMAKE_SYSTEM_PROGRAM_PATH
    )

    if(NOT CXTPL_tool_PROGRAM)
        message(WARNING "Program 'CXTPL_tool' not found, unable to run 'CXTPL_tool'.")
    endif(NOT CXTPL_tool_PROGRAM)

    # Define a function for enabling clang-tidy per target. The option above
    # makes this redundant, as it enables it for all targets already. This
    # could be used in combination with custom target commands or by
    # overriding the add_* commands with custom implementation.
    function(target_add_CXTPL_tool TARGET GUID INPUTS OUTPUTS)
      if(NOT CXTPL_tool_PROGRAM)
          message(FATAL_ERROR "Program 'CXTPL_tool' not found, unable to run 'CXTPL_tool'.")
      endif(NOT CXTPL_tool_PROGRAM)

      set_source_files_properties(
        ${OUTPUTS}
        PROPERTIES GENERATED TRUE
      )

      string (REPLACE ";" " " INPUTS_as_string "${INPUTS}")
      string (REPLACE ";" " " OUTPUTS_as_string "${OUTPUTS}")
      # NOTE: regen files at configure step
      execute_process(
        COMMAND ${CMAKE_COMMAND}
                -DCXTPL_tool_PROGRAM=${CXTPL_tool_PROGRAM}
                -DTHREADS=2
                -DINPUTS=${INPUTS_as_string}
                -DOUTPUTS=${OUTPUTS_as_string}
                -DCXTPL_tool_LOG_CONFIG=.:=DBG9:default:console\;default=file:path=CXTPL_tool_for_${TARGET}.log,async=true,sync_level=DBG9\;console=stream:stream=stderr
                -P ${FindCXTPL_tool_LIST_DIR}/run_CXTPL_tool.cmake )

      # NOTE: regen files at build step
      add_custom_target(CXTPL_tool_target_for_${TARGET}_${GUID} ALL
        COMMAND ${CMAKE_COMMAND}
                -DCXTPL_tool_PROGRAM=${CXTPL_tool_PROGRAM}
                -DTHREADS=2
                -DINPUTS="${INPUTS}"
                -DOUTPUTS="${OUTPUTS}"
                -DCXTPL_tool_LOG_CONFIG=".:=DBG9:default:console\;default=file:path=CXTPL_tool_for_${TARGET}.log,async=true,sync_level=DBG9\;console=stream:stream=stderr"
                -P ${FindCXTPL_tool_LIST_DIR}/run_CXTPL_tool.cmake )

      add_dependencies(${TARGET} CXTPL_tool_target_for_${TARGET}_${GUID})
    endfunction(target_add_CXTPL_tool)

endif(CXTPL_tool)
