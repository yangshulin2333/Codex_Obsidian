@echo off
chcp 65001
@REM svn update ../../Config
cd makedata
bin -b extend.lua --mode translation_pull --srcpath ../config
cd ..
pause