FROM debian:stretch-slim

# Versions
ENV SCALA_VERSION 2.11.8
ENV SBT_VERSION 1.0.3
ENV GRAALVM_VERSION 1.0.0-rc1

# Environment variables
ENV ROOT /root
ENV BASHRC ${ROOT}/.bashrc
ENV SCALA_HOME $ROOT/scala-${SCALA_VERSION}
ENV GRAALVM_HOME $ROOT/graalvm-${GRAALVM_VERSION}
ENV SBT_HOME $ROOT/sbt-${SBT_VERSION}
ENV PATH=$SCALA_HOME/bin:$GRAALVM_HOME/bin:$SBT_HOME/bin:$PATH

# Update base image deps
RUN apt-get update && \
    apt-get install -y curl gcc libz-dev && \
    rm -rf /var/lib/apt/lists/*

# Install GraalVM
RUN mkdir $GRAALVM_HOME && \
    curl -fsL https://github.com/oracle/graal/releases/download/vm-$GRAALVM_VERSION/graalvm-ce-$GRAALVM_VERSION-linux-amd64.tar.gz | tar -xvzf - -C $GRAALVM_HOME --strip-components=1

# Install Scala
RUN mkdir $SCALA_HOME && \
    curl -fsL https://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C $SCALA_HOME --strip-components=1

# Install sbt
RUN mkdir $SBT_HOME && \
    curl -fsL https://sbt-downloads.cdnedge.bluemix.net/releases/v$SBT_VERSION/sbt-$SBT_VERSION.tgz | tar xfz - -C $SBT_HOME --strip-components=1

# Add path to .bashrc
RUN echo >> ${BASHRC} && \
    echo "export $PATH" >> ${BASHRC}

# Set the working directory to /app
RUN mkdir -p /app
WORKDIR /app

# Share host's current directory content with container's /app directory
ADD . /app
