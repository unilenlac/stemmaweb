FROM ubuntu:18.04
MAINTAINER Tara L Andrews <tla@mit.edu>
RUN apt-get update && apt-get install -y gcc \
	make \
	libxml2-dev \
	zlib1g-dev \
	libexpat1-dev \
	graphviz \
	libssl-dev \
	libgmp-dev \
	git
RUN cpan -T App::cpanminus
RUN cpanm -n --install Module::Install::Catalyst
#Added for debug catalyst purposes
RUN cpanm -n --install Catalyst::Plugin::ErrorCatcher 
RUN apt-get install zlib1g-dev libxml2-dev
RUN cpan install XML::LibXML

COPY stemmaweb.conf stemmaweb.psgi Makefile.PL ../stemmaweb/
COPY ./lib/stemmaweb.pm ../stemmaweb/lib/

RUN cd stemmaweb && cpanm -n --installdeps .
RUN git clone https://github.com/tla/stemmatology.git

COPY ./doc ../stemmaweb/doc/
COPY ./script ../stemmaweb/script/
COPY ./t ../stemmaweb/t/
COPY ./lib ../stemmaweb/lib/
COPY ./root ../stemmaweb/root/
RUN cd stemmatology/base && perl Makefile.PL && make && make install && make distclean
WORKDIR "/stemmaweb"
CMD perl script/stemmaweb_server.pl
