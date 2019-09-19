# Type a script or drag a script file from your workspace to insert its path.

echo ${SRCROOT}
 
# 创建 Result 目录
RESULT_DIR=${SRCROOT}/Result
if [ -e "${RESULT_DIR}" ] ;then
    rm -r "${RESULT_DIR}"
fi

mkdir "${RESULT_DIR}"

echo "Copy app to result dir"
 
# 拷贝资源到result目录
RESOURCE_DIR=${SRCROOT}/Dist/
cp -R "${RESOURCE_DIR}" "${RESULT_DIR}"
 
# 拷贝 app 文件到result目录
PRODUCT_NAME=Electsys\ Utility
PRODUCT_APP="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app"
cp -R "${PRODUCT_APP}" "${RESULT_DIR}/${PRODUCT_NAME}.app"

 
cd "${RESULT_DIR}"
# package dmg
echo "package dmg..."
appdmg appdmg.json "${PRODUCT_NAME}.dmg"
 
# remove no used files
rm -rf *.app
find . -type f -not -name '*.dmg' | xargs rm -rf
