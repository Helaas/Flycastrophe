# Deadcast's own files that Flycastrophe ports (FLYCASTROPHE.md). The rest of Deadcast's
# core/deadcast (menu, OSD, netplay, link cable, upload worker) is not part of it.
target_sources(${PROJECT_NAME} PRIVATE
        codecache.cpp
        codecache.h
        mmuwindows.cpp
        mmuwindows.h
        profiler.cpp
        profiler.h
        waitloops.cpp
        waitloops.h)
