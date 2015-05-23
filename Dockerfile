FROM resin/armv7hf-debian:jessie

RUN apt-get update \
	&& apt-get install -y build-essential axel wget htop nano \
	&& apt-get clean \
        && apt-get autoremove -qqy 

RUN mkdir -p /app && cd /app \
	&& axel -n 10 http://ftp.parallella.org/esdk/esdk.2015.1_linux_armv7l-20150523.tar.gz && tar -xf esdk.2015.1_linux_armv7l-20150523.tar.gz && rm esdk.2015.1_linux_armv7l-20150523.tar.gz \
	&& wget https://github.com/adapteva/epiphany-examples/archive/2015.1.tar.gz && tar -xf 2015.1.tar.gz && rm 2015.1.tar.gz

ENV EPIPHANY_HOME /app/esdk.2015.1

# Enable default setup from webterminal
RUN sed -i 's/\/bin\/sh/\/bin\/bash/g' /app/esdk.2015.1/setup.sh && echo "source /app/esdk.2015.1/setup.sh" >> ~/.bashrc

ADD . /app

# Fix the permissions of run.sh and build.sh for pushes from windows.
RUN chmod a+x /app/run.sh /app/build.sh

# Source the setup and build the example.
RUN bash -c "source /app/esdk.2015.1/setup.sh && ./app/build.sh"

# Run this on startup.
CMD bash -c " source /app/esdk.2015.1/setup.sh && cd /app && ./run.sh && while true; do sleep 60; done "
