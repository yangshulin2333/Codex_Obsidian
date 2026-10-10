@echo off
chcp 65001
@REM svn update ../../Config
cd makedata
bin -b extend.lua --mode translation_export --srcpath ../config
cd ..
pause