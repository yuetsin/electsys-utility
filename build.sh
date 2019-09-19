#!/bin/bash
TOP_DIR=$(pwd)
echo "----TOP_DIR----"
echo $TOP_DIR
 

CONFIGURATION=Release
BUILD_SCHEME=Package

cd Electsys\ Utility
xcodebuild -workspace Electsys\ Utility.xcworkspace -scheme ${BUILD_SCHEME} -configuration ${CONFIGURATION}

echo "Build succeed"

#————————————————
#版权声明：本文为CSDN博主「huilibai」的原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接及本声明。
#原文链接：https://blog.csdn.net/huilibai/article/details/83659399
