@echo off
lua ./assist/reload.lua

chcp 65001
@REM svn update ../../Config
@REM svn update ./makedata
cd makedata
set source= ../config
set output= ../src/ReplicatedStorage/Config
set mloutput= ../src/ReplicatedStorage
bin -b main.lua --srcpath %source% --dstpath %output% --mldstpath %mloutput%
cd ..

chcp 65001
@REM svn update ../../Config
cd makedata
bin -b extend.lua --mode translation_export --srcpath ../config
cd ..

chcp 65001
@REM svn update ../../Config
cd makedata
bin -b extend.lua --mode translation_pull --srcpath ../config
cd ..

chcp 65001
@REM svn update ../../Config
cd makedata
bin -b extend.lua --mode translation_merge --srcpath ../config
cd ..

chcp 65001
@REM svn update ../../Config
@REM svn update ./makedata
cd makedata
set source= ../Config
set output= ../src/ReplicatedStorage/Config
set mloutput= ../src/ReplicatedStorage
bin -b main.lua --srcpath %source% --dstpath %output% --mldstpath %mloutput%
cd ..

lua ./assist/config_mark.lua
pause