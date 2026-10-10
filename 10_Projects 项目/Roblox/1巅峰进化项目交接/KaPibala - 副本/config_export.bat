@echo off
chcp 65001
@REM svn update ../../Config
@REM svn update ./makedata
cd makedata
set source= ../config
set output= ../src/ReplicatedStorage/Config
set mloutput= ../src/ReplicatedStorage
bin -b main.lua --srcpath %source% --dstpath %output% --mldstpath %mloutput%
cd ..
config_mark
pause