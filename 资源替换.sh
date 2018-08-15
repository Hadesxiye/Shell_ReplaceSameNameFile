#!/bin/bash
echo ""
echo "❀---                (*ﾟ∀ﾟ)Start                ---❀"
echo "|                                                 |"
echo "|                 create by hades                 |"
echo "|                                                 |"
echo "| ⚠️ 用来覆盖的资源文件应放在同一文件夹根目录中 ⚠️  |"
echo "| ⚠️  放在此文件夹子目录的资源文件不会被识别   ⚠️   |"
echo "|                                                 |"
echo "|                                                 |"
echo -e "💡请输入提供替换资源的文件夹路径\n当前路径为${PWD}\n💡注意资源文件应都放在此文件夹根目录中，并且请勿放入文件夹"

read InputDir
if [ ! -n "$InputDir" ]; then
  echo "|                                                 |"
  echo "|              ❌请输入替换资源的目录             |"
  echo "|                                                 |"
  exit
else
echo "|                                                 |"
echo "📂你输入的文件夹路径为${InputDir}"
echo "|                                                 |"

#资源文件内资源名字txt
touch sourceFileName.txt
#资源文件内资源路径txt
touch sourceFileDir.txt
#为找到结果的资源txt
touch sourceUnfindName.txt
#创建记录txt
touch FindResult.txt

FindResultDir="${PWD}/FindResult.txt"
OutputFile="${PWD}/sourceFileName.txt"
OutputFileDir="${PWD}/sourceFileDir.txt"
UnfindSourceDir="${PWD}/sourceUnfindName.txt"

#清空txt
: > "$UnfindSourceDir"
: > "$OutputFileDir"
: > "$OutputFile"
#循环读取文件夹名
for file_a in ${InputDir}/*
 do
    temp_file=`basename $file_a`
    temp_fileDir=${PWD}/$temp_file
    echo $temp_fileDir >> $OutputFileDir
    echo $temp_file >> $OutputFile
done

#获取输出log的文件
temp=${OutputFile}
#获取对应文件名
temp=${temp##*/}
echo $temp
#对log文件进行行数判断
sourceFileNumber=$(awk '{print NR}' $temp|tail -n1)
echo "|                                                 |"
echo "---         资源文件个数为: $sourceFileNumber         ---"
echo "|                                                 |"
echo "|          📂请输入替换资源的目标文件目录：       |"

read TargetFileDir

if [ ! -n "$TargetFileDir" ]; then
  echo "|                                                 |"
  echo "|            ❌请输入需要替换资源的目录           |"
  echo "|                                                 |"
  exit
else


for ((i=1;i<=$sourceFileNumber;i++))
  do
    #获取指定行数的资源名字
    sourceNameTemp=$(awk 'NR=="'$i'" {print;exit}' $OutputFile)
    echo "|                                                 |"
    echo "    $i 资源文件--- $sourceNameTemp ---开始查找      "
    echo "|                                                 |"

    #获取指定行数的资源路径
    sourceDirTemp=$(awk 'NR=="'$i'" {print;exit}' $OutputFileDir)

    #清空FindResultDir
    : > "$FindResultDir"

    #开始查找,每次的结果输入FindResultDir.txt
    find "$TargetFileDir" -name "$sourceNameTemp" >> "$FindResultDir"
    echo $FindResultDir

    #判断txt中是否有结果
    FindResultDir_name=${FindResultDir##*/}
    echo $FindResultDir_name
    FindResultDirNumber=$(awk '{print NR}' "$FindResultDir_name"|tail -n1)

    #先对找到的结果做判断 是否为null
    #echo $FindResultDirNumber

    #txt为空 则没同名资源
    if [ ! -n "$FindResultDirNumber" ]; then
      echo "|                                                 |"
      echo "          ❌未找到目标资源--$sourceNameTemp"
      echo "|                                                 |"
      # >> 追加到unfind.txt  > 为覆盖
      echo "$sourceNameTemp" >> "$UnfindSourceDir"

    #txt不为空，有同名资源
    else
      echo "|                                                 |"
      echo "          ✅搜索结果为 $FindResultDirNumber 个"
      echo "|                                                 |"

      #获取结果txt内容 根据行数做循环替换
      for ((a=1;a<=$FindResultDirNumber;a++))
        do
          FindResult=$(awk 'NR=="'$a'" {print;exit}' "$FindResultDir")
          if [ ! "$FindResult" ]; then
            echo "|                                                 |"
            echo "      ❗️❗️❗️搜索到结果但目标资源异常或路径变更，替换失败"
            echo "|                                                 |"
          else
            echo "|                                                 |"
            echo " 💾目标资源替换--$FindResult"
            echo "|                                                 |"

            #获取原生资源和替换资源的路径
            #替换资源路径为 $sourceDirTemp
            #目标资源是 $FindResult
            echo $sourceDirTemp
            echo $FindResult
            cp -f "$sourceDirTemp" "$FindResult"
            echo "|                                                 |"
            echo "🍺使用 $sourceDirTemp 替换 $FindResult 完成！"
            echo "|                                                 |"
          fi
        done
    fi
  done

  echo "|                                                 |"
  echo "|                 未找到的资源如下                |"
  cat "$UnfindSourceDir" | while read LINE
  do

    echo $LINE

  done
  echo "|                     over                        |"
  echo "|                                                 |"
#处理完成 删除log文件
echo "|                                                 |"
echo "|                   删除临时文件                  |"
echo "|                                                 |"
echo "|------               finish                ------|"
#read
rm "$OutputFile"
rm "$FindResultDir"
rm "$OutputFileDir"
rm "$UnfindSourceDir"

fi
fi
