includeexternal ("premake5-include.lua")

workspace "tools"
    language "C++"
    location "build/%{_ACTION}/%{wks.name}"    

    configurations { "Debug", "Release", "TRACE", "TRACE_MT" }
    platforms { "Win32", "x64" }    

    filter { "kind:StaticLib", "platforms:Win32" }
        targetdir "lib/x86/%{_ACTION}" 
    filter { "kind:StaticLib", "platforms:x64" }
        targetdir "lib/x64/%{_ACTION}" 
    filter { "kind:SharedLib", "platforms:Win32" }
        implibdir "lib/x86/%{_ACTION}" 
    filter { "kind:SharedLib", "platforms:x64" }
        implibdir "lib/x64/%{_ACTION}" 
    filter { "kind:ConsoleApp or WindowedApp or SharedLib", "platforms:Win32" }
        targetdir "bin/x86/%{_ACTION}/%{wks.name}"         
    filter { "kind:ConsoleApp or WindowedApp or SharedLib", "platforms:x64" }
        targetdir "bin/x64/%{_ACTION}/%{wks.name}" 
        

    filter { "platforms:Win32" }
        system "Windows"
        architecture "x32"
        libdirs 
        {
            "lib/x86/%{_ACTION}",
            "lib/x86/%{_ACTION}/boost-1_56",
            "lib/x86/%{_ACTION}/boost-1_60",
            "bin/x86/%{_ACTION}"            
        }
    
    filter { "platforms:x64" }
        system "Windows"
        architecture "x64"   
        libdirs
        {
            "lib/x64/%{_ACTION}",
            "lib/x64/%{_ACTION}/boost-1_56",
            "lib/x64/%{_ACTION}/boost-1_60",
            "bin/x64/%{_ACTION}"
        }

    filter "configurations:Debug"
        defines { "DEBUG" }
        flags { "Symbols" }

    filter "configurations:Release"
        defines { "NDEBUG" }
        flags { "Symbols" }
        optimize "Speed"  
        buildoptions { "/Od" } 
    
    filter "configurations:TRACE"
        defines { "NDEBUG", "TRACE_TOOL" }
        flags { "Symbols" }
        optimize "Speed"  
        buildoptions { "/Od" } 
        includedirs
        {            
            "3rdparty"    
        }  
        links { "tracetool.lib" }         

    filter "configurations:TRACE_MT"
        defines { "NDEBUG", "TRACE_TOOL" }
        flags { "Symbols" }
        optimize "On"  
        buildoptions { "/Od" }  
        includedirs
        {            
            "3rdparty"    
        }    
        links { "tracetool_mt.lib" }        

    configuration "vs*"
        warnings "Extra"                    -- 开启最高级别警告
        defines
        {
            "WIN32",
            "WIN32_LEAN_AND_MEAN",
            "_WIN32_WINNT=0x501",           -- 支持到 xp
            "_CRT_SECURE_NO_WARNINGS",        
            "_CRT_SECURE_NO_DEPRECATE",            
            "STRSAFE_NO_DEPRECATE",
            "_CRT_NON_CONFORMING_SWPRINTFS"
        }
        buildoptions
        {
            "/wd4267",                      -- 关闭 64 位检测
            "/wd4996"
        }    
        
    print("test")

    function create_console_project(name, dir, mbcs)        
        project(name)          
        kind "ConsoleApp"                          
        if mbcs == "mbcs" then
            characterset "MBCS"
        end
        flags { "NoManifest", "WinMain", "StaticRuntime" }       
        defines {  }
        files
        {                                  
            dir .. "/%{prj.name}/**.h",
            dir .. "/%{prj.name}/**.cpp", 
            dir .. "/%{prj.name}/**.c", 
            dir .. "/%{prj.name}/**.rc" 
        }
        removefiles
        {               
        }
        includedirs
        {                   
            "3rdparty"   
        }       
        links
        {
            "Wtsapi32.lib"
        }
    end

    function create_sys_project(name, dir)
        project(name)          
        targetextension ".sys"
        kind "WindowedApp"               
        buildoptions { "/X", "/Gz", "/GR-" } 
        --linkoptions { "/SUBSYSTEM:NATIVE", "/DRIVER", "/ENTRY:\"DriverEntry\"", "/NODEFAULTLIB" }
        linkoptions { "/SUBSYSTEM:NATIVE", "/DRIVER", "/ENTRY:\"DriverEntry\"" }
        flags { "StaticRuntime", "NoManifest", "No64BitChecks", "NoBufferSecurityCheck", "NoRuntimeChecks" }
        files
        {
            dir .. "/%{prj.name}/**.h",
            dir .. "/%{prj.name}/**.cpp", 
            dir .. "/%{prj.name}/**.c", 
            dir .. "/%{prj.name}/**.rc" 
--            "3rdparty/WinRing0/**.h",
--            "3rdparty/WinRing0/**.c",
--            "3rdparty/WinRing0/**.cpp",
--            "3rdparty/WinRing0/**.rc"                
        }
        removefiles
        {               
        }
        includedirs
        {   
            "C:/WinDDK/7600.16385.1/inc/ddk",
            "C:/WinDDK/7600.16385.1/inc/api",
            "C:/WinDDK/7600.16385.1/inc/crt",
            "C:/Program Files (x86)/Microsoft Visual Studio 8/VC/include"
        }
        --pchsource "3rdparty/WinRing0/stdafx.cpp"
        --pchheader "stdafx.h"               
        defines { "WIN32", "_CONSOLE", "_DDK_" }
        filter { "platforms:Win32" }
            defines { "_X86_" }     
            libdirs
            {
                "C:/WinDDK/7600.16385.1/lib/WIN7/i386"
                
            }
            links
            { 
                "ntoskrnl.lib",
                "hal.lib",
                "int64.lib",
                "ntstrsafe.lib",
                "exsup.lib",
                "ksecdd.lib"                      
            }            
        filter "platforms:x64"
            defines { "_AMD64_" }
            libdirs
            {
                "C:/WinDDK/7600.16385.1/lib/WIN7/amd64"                    
            }
            links
            { 
                "ntoskrnl.lib",
                "hal.lib",                    
                "ntstrsafe.lib",                    
                "ksecdd.lib"                      
            }            
            targetsuffix "x64"
        filter "configurations:Debug"
            defines { "_DEBUG", "DBG=1" }
        filter "configurations:Release"
            defines { "_NDEBUG", "DBG=0" }
            buildoptions { "/Ob2", "/Oi", "/GL" } 
    end



    group "tools"            

        --create_console_project("file-2-hex", "src/tools")         
        --create_console_project("bin2cpp", "hack-tools", "mbcs")        
               
        
        project "file-2-hex"            
            kind "ConsoleApp"                         
            flags { "NoManifest", "WinMain" }  
            defines { "STATIC_GETOPT", "FILE_2_HEX_EXE" }
            files
            {
                "3rdparty/getopt/**.h",
                "3rdparty/getopt/**.c",                
                "src/%{wks.name}/%{prj.name}/**.h",
                "src/%{wks.name}/%{prj.name}/**.cpp",
                "include/buildcfg/vs2015/buildcfg.h",
                "include/buildcfg/vs2015/version.rc",                
                "include/buildcfg/vs2015/versionno.rc2"
            }
            removefiles
            {               
            }
            includedirs
            {                   
                "3rdparty/getopt",
                "include/buildcfg/vs2015/",
                
            }
            links
            { 
                
            }
            libdirs
            {
                     
            }


        project "serise-key"            
            kind "ConsoleApp"                         
            flags { "NoManifest", "WinMain" }  
            defines { "STATIC_GETOPT", "FILE_2_HEX_EXE" }
            files
            {
                "3rdparty/getopt/**.h",
                "3rdparty/getopt/**.c",                
                "src/%{wks.name}/%{prj.name}/**.h",
                "src/%{wks.name}/%{prj.name}/**.cpp",
                "include/buildcfg/vs2015/buildcfg.h",
                "include/buildcfg/vs2015/version.rc",                
                "include/buildcfg/vs2015/versionno.rc2"
            }
            removefiles
            {               
            }
            includedirs
            {                   
                "3rdparty/getopt",
                "include/buildcfg/vs2015/",
                
            }
            links
            { 
                
            }
            libdirs
            {
                     
            }

        project "wtl_dialog_basic"          
            kind "WindowedApp"          
            flags { "NoManifest", "WinMain", "StaticRuntime" }       
            defines {  }            
            files
            {                                  
                "src/%{wks.name}/%{prj.name}/**.h",
                "src/%{wks.name}/%{prj.name}/**.cpp", 
                "src/%{wks.name}/%{prj.name}/**.rc" 
            }
            removefiles
            {               
            }
            includedirs
            {                   
                "3rdparty/wtl"   
            } 
            links
            { 
                "winmm.lib"
            }       

    group "DuiLib"

        project "DuiLib"            
            kind "SharedLib"                         
            flags { "NoManifest" }  
            defines { "UILIB_EXPORTS", "FILE_2_HEX_EXE" }
            files
            {

                "src/dui-examples/%{prj.name}/**.h",
                "src/dui-examples/%{prj.name}/**.cpp",
                "src/dui-examples/%{prj.name}/**.c",
                "include/buildcfg/vs2015/buildcfg.h",
                "include/buildcfg/vs2015/version.rc",                
                "include/buildcfg/vs2015/versionno.rc2"
            }
            removefiles
            {               
            }
            includedirs
            {                   
                "src/dui-examples/DuiLib/",
                "include/buildcfg/vs2015/",
                
            }
            links
            { 
                
            }
            libdirs
            {
                     
            }
            pchsource "src/dui-examples/%{prj.name}/StdAfx.cpp"
            pchheader "StdAfx.h"           
            filter "files:src/dui-examples/DuiLib/Utils/XUnzip.cpp"
                flags { "NoPCH" }
            filter "files:src/dui-examples/DuiLib/**.c"
                flags { "NoPCH" }


        
        

        project "example01"            
            kind "WindowedApp"                         
            flags { "NoManifest", "WinMain" }  
            defines { "UILIB_EXPORTS", "FILE_2_HEX_EXE" }
            files
            {

                "src/dui-examples/%{prj.name}/**.h",
                "src/dui-examples/%{prj.name}/**.cpp",
                "src/dui-examples/%{prj.name}/**.c",
                "include/buildcfg/vs2015/buildcfg.h",
                "include/buildcfg/vs2015/version.rc",                
                "include/buildcfg/vs2015/versionno.rc2"
            }
            removefiles
            {               
            }
            includedirs
            {                   
                "src/dui-examples/DuiLib/",
                "include/buildcfg/vs2015/",
                
            }
            links
            { 
                "DuiLib.lib"
            }
            libdirs
            {
                     
            }

        project "example02"            
            kind "WindowedApp"                         
            flags { "NoManifest", "WinMain" }  
            defines { "UILIB_EXPORTS", "FILE_2_HEX_EXE" }
            files
            {

                "src/dui-examples/%{prj.name}/**.h",
                "src/dui-examples/%{prj.name}/**.cpp",
                "src/dui-examples/%{prj.name}/**.c",
                "src/dui-examples/%{prj.name}/**.rc",
                "include/buildcfg/vs2015/buildcfg.h",
                "include/buildcfg/vs2015/version.rc",                
                "include/buildcfg/vs2015/versionno.rc2"
            }
            removefiles
            {               
            }
            includedirs
            {                   
                "src/dui-examples/DuiLib/",
                "include/buildcfg/vs2015/",
                
            }
            links
            { 
                "DuiLib.lib"
            }
            libdirs
            {
                     
            }

        project "example03"            
            kind "WindowedApp"                         
            flags { "NoManifest", "WinMain" }  
            defines { "UILIB_EXPORTS", "FILE_2_HEX_EXE" }
            files
            {

                "src/dui-examples/%{prj.name}/**.h",
                "src/dui-examples/%{prj.name}/**.cpp",
                "src/dui-examples/%{prj.name}/**.c",
                "src/dui-examples/%{prj.name}/**.rc",
                "include/buildcfg/vs2015/buildcfg.h",
                "include/buildcfg/vs2015/version.rc",                
                "include/buildcfg/vs2015/versionno.rc2"
            }
            removefiles
            {               
            }
            includedirs
            {                   
                "src/dui-examples/DuiLib/",
                "include/buildcfg/vs2015/",
                
            }
            links
            { 
                "DuiLib.lib"
            }
            libdirs
            {
                "src/dui-examples/example03"     
            }

        project "dui_example_cmd"            
            kind "WindowedApp"                         
            flags { "NoManifest", "WinMain" }  
            defines { "UILIB_EXPORTS", "FILE_2_HEX_EXE" }
            files
            {

                "src/dui-examples/%{prj.name}/**.h",
                "src/dui-examples/%{prj.name}/**.cpp",
                "src/dui-examples/%{prj.name}/**.c",
                "include/buildcfg/vs2015/buildcfg.h",
                "include/buildcfg/vs2015/version.rc",                
                "include/buildcfg/vs2015/versionno.rc2"
            }
            removefiles
            {               
            }
            includedirs
            {                   
                "src/dui-examples/DuiLib/",
                "include/buildcfg/vs2015/",
                
            }
            links
            { 
                "DuiLib.lib"
            }
            libdirs
            {
                     
            }

    group "UiLib"

        project "UiLib"            
            kind "SharedLib"                         
            flags { "NoManifest" }  
            defines { "UILIB_EXPORTS", "FILE_2_HEX_EXE" }
            files
            {

                "src/dui-examples/%{prj.name}/**.h",
                "src/dui-examples/%{prj.name}/**.cpp",
                "src/dui-examples/%{prj.name}/**.c",
                "include/buildcfg/vs2015/buildcfg.h",
                "include/buildcfg/vs2015/version.rc",                
                "include/buildcfg/vs2015/versionno.rc2"
            }
            removefiles
            {               
            }
            includedirs
            {                   
                "src/dui-examples/UiLib/",
                "include/buildcfg/vs2015/",
                
            }
            links
            { 
                
            }
            libdirs
            {
                     
            }
            pchsource "src/dui-examples/%{prj.name}/StdAfx.cpp"
            pchheader "StdAfx.h"           
            filter "files:src/dui-examples/UiLib/Utils/XUnzip.cpp"
                flags { "NoPCH" }
            filter "files:src/dui-examples/UiLib/**.c"
                flags { "NoPCH" }


        project "cloneKuGou"            
            kind "WindowedApp"                         
            flags { "NoManifest", "WinMain" }  
            defines { "UILIB_EXPORTS", "FILE_2_HEX_EXE" }
            files
            {

                "src/dui-examples/%{prj.name}/**.h",
                "src/dui-examples/%{prj.name}/**.cpp",
                "src/dui-examples/%{prj.name}/**.c",
                "src/dui-examples/%{prj.name}/**.rc",
                "include/buildcfg/vs2015/buildcfg.h",
                "include/buildcfg/vs2015/version.rc",                
                "include/buildcfg/vs2015/versionno.rc2"
            }
            removefiles
            {               
            }
            includedirs
            {                   
                "src/dui-examples/UiLib/",
                "include/buildcfg/vs2015/",
                
            }
            links
            { 
                "UiLib.lib"
            }
            libdirs
            {
                "src/dui-examples/cloneKuGou"     
            }
           
        
        project "win360"            
            kind "WindowedApp"                         
            flags { "NoManifest", "WinMain" }  
            defines { "UILIB_EXPORTS", "FILE_2_HEX_EXE" }
            files
            {

                "src/dui-examples/%{prj.name}/**.h",
                "src/dui-examples/%{prj.name}/**.cpp",
                "src/dui-examples/%{prj.name}/**.c",
                "src/dui-examples/%{prj.name}/**.rc",
                "include/buildcfg/vs2015/buildcfg.h",
                "include/buildcfg/vs2015/version.rc",                
                "include/buildcfg/vs2015/versionno.rc2"
            }
            removefiles
            {               
            }
            includedirs
            {                   
                "src/dui-examples/DuiLib/",
                "include/buildcfg/vs2015/",
                
            }
            links
            { 
                "DuiLib.lib"
            }
            libdirs
            {
                
            }

    
        
    group "tracetool"

        project "tracetool"
            removeconfigurations "TRACE*"            
            kind "StaticLib"                    
            files
            {
                "3rdparty/tracetool/**.h",
                "3rdparty/tracetool/**.cpp"                
            }             

        project "tracetool_mt"
            removeconfigurations "TRACE*"            
            kind "StaticLib"          
            flags { "StaticRuntime" }                 
            targetname "tracetool_mt"
            files
            {
                "3rdparty/tracetool/**.h",
                "3rdparty/tracetool/**.cpp"                
            }           



        