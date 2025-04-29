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
# COPY Makefile ../stemmaweb/
# COPY META.yml ../stemmaweb/
# COPY MYMETA.yml ../stemmaweb/
COPY stemmaweb.conf stemmaweb.psgi Makefile.PL ../stemmaweb/
COPY ./lib/stemmaweb.pm ../stemmaweb/lib/
#RUN git clone https://github.com/tla/stemmaweb.git (IMPORTANT: link deprecated, returning new project with modern tech, aka: uncompatible)
#RUN git clone https://github.com/unilenlac/stemmaweb.git --branch IRSB
RUN cd stemmaweb && cpanm -n --installdeps .
RUN git clone https://github.com/tla/stemmatology.git
# COPY ./blib ../stemmaweb/blib/ 
# COPY ./dependencies_local ../stemmaweb/dependencies_local/
COPY ./doc ../stemmaweb/doc/
# COPY ./inc ../stemmaweb/inc/
COPY ./script ../stemmaweb/script/
COPY ./t ../stemmaweb/t/
COPY ./lib ../stemmaweb/lib/
COPY ./root ../stemmaweb/root/
RUN cd stemmatology/base && perl Makefile.PL && make && make install && make distclean
WORKDIR "/stemmaweb"
CMD perl -d script/stemmaweb_server.pl
# CMD /bin/bash
