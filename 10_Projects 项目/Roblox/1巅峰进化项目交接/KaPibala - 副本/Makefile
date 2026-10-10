desc_path  = ../config_desc/descriptor 	# desc文件路径
trans_path = ../config_desc/transform 	# transform脚本路径
guard_path = ../config_desc/guard 		# guard脚本路径
excel_path = ../config 					# excel配置表路径
lua_data_path   = ../src/ReplicatedStorage/Config 				# lua数据表输出路径
lua_mlang_path  = ../src/ReplicatedStorage                # lua多语言表输出路径

test:
	@make data
	@make tolua
	@make reload
	@make marker
	@make rojo

all: 
	@make data
	@make tolua
	@make export
	@make pull
	@make merge
	@make tolua
	@make reload
	@make marker
	@make rojo

cfg:
	@make reload
	@make tolua
	@make marker

cfg_all:
	@make reload
	@make tolua
	@make marker
	@make export 
	@make pull 
	@make merge 
	@make tolua

tolua:
	@echo '==============================================='
	@echo '       转换: Excel -> Lua'
	@echo '==============================================='
	@cd makedata && git checkout mac && lnet -b main.lua --op tolua --descpath ${desc_path} --transpath ${trans_path} --guardpath ${guard_path} --srcpath ${excel_path} --dstpath ${lua_data_path} --mldstpath ${lua_mlang_path} && git checkout main
	@echo
	@rm -rf ./makedata/0temp
test_tolua:
	@echo '==============================================='
	@echo '       转换: Excel -> Lua'
	@echo '==============================================='
	@cd makedata && git checkout mac && lnet -b main.lua --op tolua --descpath ${desc_path} --transpath ${trans_path} --guardpath ${guard_path} --srcpath ${excel_path} --dstpath ${lua_data_path} --mldstpath ${lua_mlang_path}
	@echo
	@rm -rf ./makedata/0temp

export:
	@echo '================================================'
	@echo '       导出: DictMain -> DictTranslate'
	@echo '================================================'
	@cd makedata && git checkout mac && lnet -b main.lua --op translation --mode translation_export --srcpath ${excel_path} && git checkout main
	@echo

pull:
	@echo '================================================='
	@echo '       拉取: DictTranslate'
	@echo '================================================='
	@cd makedata && git checkout mac && lnet -b main.lua --op translation --mode translation_pull --srcpath ${excel_path} && git checkout main
	@echo

merge:
	@echo '================================================='
	@echo '       合并: DictTranslate -> DictMain'
	@echo '================================================='
	@cd makedata && git checkout mac && lnet -b main.lua --op translation --mode translation_merge --srcpath ${excel_path} && git checkout main
	@echo

data:
	@echo '================================================='
	@echo '       拉取数据: 数据表 -> Config'
	@echo '================================================='
	@cd makedata && git checkout main && cd .. &&python3 makedata/python/DataExportEx.py --input document/数据表.xlsm --output config
	@echo

submodule:
	@echo '================================================='
	@echo '       初始化子仓库: git -> local'
	@echo '================================================='
	@git submodule update --init api && git submodule update --init src/ReplicatedStorage/Hotpot && git submodule update --init src/ServerStorage/Hotpot && git submodule update --init makedata
	@echo

reload:
	@echo '================================================='
	@echo '       扫描目录: all file -> file list'
	@echo '================================================='
	@lua ./assist/reload.lua
	@echo

marker:
	@echo '================================================='
	@echo '       添加配置注释: config file -> lua file'
	@echo '================================================='
	@lua ./assist/config_mark.lua
	@echo
main_to_dev:
	@echo '================================================='
	@echo '       git合并main到dev分支: main -> dev'
	@echo '================================================='
	@git checkout main
	@git fetch
	@git pull
	@git checkout dev
	@git merge main
	@echo
dev_to_main:
	@echo '================================================='
	@echo '       git合并dev到main分支: dev -> main'
	@echo '================================================='
	@git checkout main
	@git fetch
	@git pull
	@git merge dev
	@echo

rojo:
	@echo '================================================='
	@echo '       正在启动Rojo Server'
	@echo '================================================='
	@rojo serve
