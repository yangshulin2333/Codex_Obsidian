//--------------------------------------
//	导表描述块格式
//--------------------------------------
//
// EXCEL_FILENAME {
//	out: OUTPUT_NAME         		若不提供out选项 则以EXCEL_FILENAME作为输出文件名 
//	cols:  FIELD_NAME, ...   		指定包含的字段
//		   $ex, FIELD_NAME, ...     指定排除的字段
//		   							若不提供cols选项 则包含全部字段
//	unique: true					是否是单记录excel文件 指定该选项 可以减少一层嵌套
//  multlang: FIELD_NAME, ...    需要多语言处理的字段
//	conv: {
//		FIELD_NAME: 				字段转换模式 下详
//	}
// }

//--------------------------------------
//	字段转换模式
//--------------------------------------
// 原样 			$raw
// 数组 			$array
// 结构体 			$struct FILED_NAME, ...
// 带权值的结构体 	 $weight FILED_NAME, ...
// 自定义输出格式 	 $format LUA_FORMAT_STRING

//--------------------------------------
//	$format 注意事项
//--------------------------------------
// 1 仅支持%s和%q两种lua格式化选项
// 2 格式化串要用引号包起来

//--------------------------------------
//	例子
//--------------------------------------
// sample {
// out: sample
//	cols: $ex id;
//	unique: true;
//	conv: {
//		raw: $raw;
//		array: $array;
//		array0: ;   (仅包含分号的条目 自动继承上一个条目的模式 此处array0也是$array模式)
//		struct: $struct tid value;
//		weight: $weight tid g;
//		format: $format "[%s]={tid=%s,count=%s}";
//	}
// }