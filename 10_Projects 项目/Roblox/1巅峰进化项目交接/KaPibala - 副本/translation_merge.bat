@echo off
chcp 65001
@REM svn update ../../Config
cd makedata
bin -b extend.lua --mode translation_merge --srcpath ../config
cd ..
pause