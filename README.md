# scala-graalvm-docker

This project provides a collection of docker images to facilitate the usage of GraalVM by Scala projects, guaranteeing a consistent and reproducible environment where native images can be produced in an automated fashion.

> "Make development more productive and run programs faster anywhere." - GraalVM


## Goal

Accelerate GraalVM's adoption during develop, test, and release phases of Scala projects.


## Available

Scala: 2.11.8 and 2.12.6

SBT: From 0.13.15 until 1.1.5

GraalVM: 1.0.0-RC1

List of tags: [cloudscala/scala-graalvm:{tags}](https://hub.docker.com/r/cloudscala/scala-graalvm/tags/)


## How to use


Automating the development, testing, and release process will vary based on the needs of a project, but the following example could fit all cases. This repo contains a `docker-compose-example.yml` as an example of how to use an image.


```docker-compose
version: '3'

services:
  app:
    image: cloudscala/scala-graalvm:scala-2.12.6-sbt-1.1.5-graalvm-1.0.0-rc1
    command: ./generate-native-image-example.sh
    volumes:
      - .:/app
      - ~/.ivy2:/root/.ivy2
      - ~/.sbt:/root/.sbt
      - ~/.coursier:/root/.coursier 
```


By opening the console and running `docker-compose run app`; the docker-compose file must be in the project's root level, docker-compose will pull the version `scala-2.12.6-sbt-1.1.5-graalvm-1.0.0-rc1` and we execute the `./generate-native-image-example.sh` when the container boots up. Also, notice that the we share the current directory and known artifact folders with the container to avoid having the container's SBT loading all artificats everytime.


The `generate-native-image-example.sh`:

```shell
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
```


Creates a `native-image` folder in the project folder, triggers SBT's task `sbt assembly`, moves the created `.jar` to `native-image` folder, and at last but not least, generates the native image using GRAALVM `native-image` command.


Once the executable is ready in the `native-image` folder, we can run it inside the very same container, by changing the `command` in the `docker-compose` to point to `./native-image/{GENERATED-EXECUTABLE-FILE}`, or ship it to S3, or create a new docker image and publish to AWS ECR, etc... what to do with the executable is matter of creativity.


Note that we presume that the current Scala project is using [sbt-assembly](https://github.com/sbt/sbt-assembly) plugin, but any other plugin could be used, like [sbt-pack](https://github.com/xerial/sbt-pack), [sbt-native-packager](https://www.scala-sbt.org/sbt-native-packager/), [sbt-onejar](https://github.com/sbt/sbt-onejar), and [sbt-proguard](https://github.com/sbt/sbt-proguard).


## Spark Job example


The folder `spark-job-graalvm-example` contains an example where it uses the docker-compose and shell above.


[![asciicast](https://asciinema.org/a/181286.png)](https://asciinema.org/a/181286)


## References and Inspiration

- [GraalVM](https://www.graalvm.org/)
- [An experiment running http4s as native image with Graal (+ Substrate)](https://github.com/hhandoko/http4s-graal)
- [GraphQL server built with sangria, http4s and circe which compiles and runs as a GraalVM native image.](https://github.com/OlegIlyenko/sangria-http4s-graalvm-example)
- [An example of sangria + circe app compiled with GraalVM native-image](https://github.com/OlegIlyenko/graalvm-sangria-test)
- [Running Play on GraalVM](https://blog.playframework.com/play-on-graal/)
- [Native Clojure with GraalVM](https://www.innoq.com/en/blog/native-clojure-and-graalvm/)
- [Oracles GraalVM für "Native Java"?](https://www.innoq.com/de/blog/native-java-graalvm/)
- [Running Apache Spark jobs on Azure Kubernetes Service](https://docs.microsoft.com/en-us/azure/aks/spark-job)
- [Scala and sbt Dockerfile](https://github.com/hseeberger/scala-sbt)
- [Build sbt using Docker](https://github.com/jaceklaskowski/docker-builds-sbt)


## License

MIT License

Copyright (c) 2018 Vitor S. Vieira

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.