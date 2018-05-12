#!/bin/sh

set -e

# Set distribution folder from first argument, otherwise default to `native`
NATIVE_IMAGE_FOLDER=native-image
if [ $# -gt 0 ]; then
	NATIVE_IMAGE_FOLDER=$1
fi

# Create native-image folder if it doesn't exist, and clear the contents
mkdir -p ${NATIVE_IMAGE_FOLDER}
rm -rf ${NATIVE_IMAGE_FOLDER}/*

# Create an .jar using sbt-assembly
sbt -mem 2048 clean assembly

# Move .jar to native-image folder
find "." -name '*.jar' | while read APP_JAR; do
	mv $APP_JAR $NATIVE_IMAGE_FOLDER
done

# Go to native-image folder and generate the executables for each .jar
cd $NATIVE_IMAGE_FOLDER

find "." -name '*.jar' | while read APP_JAR; do
	echo "Processing .jar '$APP_JAR' on $NATIVE_IMAGE_FOLDER folder"
	native-image -J-Xmx2G -J-Xms2G --no-server -H:+ReportUnsupportedElementsAtRuntime -jar ${APP_JAR}
done
