# Builds an ensembl server that relays API calls to an ensembl database

FROM ubuntu

# need git to pull latest code from ensembl, etc.
# need cpanminus to run cpanm
# need make/gcc (in build-essential) to configure DBI 
# need libmysqlclient-dev to configure DBD::mysql
# XML::Parser requires expat and can't find it (libxml-parser-perl)
# Configure failed for XML-LibXML-2.0122 perl module, use OS package
RUN apt-get update && apt-get -y install python curl unzip build-essential cpanminus libmysqlclient-dev git libxml-parser-perl libxml2-dev

#install awscli
RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
RUN unzip awscli-bundle.zip
RUN ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

# setup working directory
ENV HOME /opt
WORKDIR $HOME
RUN mkdir -p src
WORKDIR $HOME/src

# get bioperl
RUN git clone https://github.com/bioperl/bioperl-live.git
WORKDIR $HOME/src/bioperl-live
RUN git checkout bioperl-release-1-6-9

# get ensembl
WORKDIR $HOME/src
RUN git clone https://github.com/Ensembl/ensembl-git-tools.git
ENV PATH $HOME/src/ensembl-git-tools/bin:$PATH
RUN git ensembl --clone api
RUN git clone https://github.com/Ensembl/ensembl-tools.git
RUN git clone https://github.com/Ensembl/ensembl-rest

# specify version of ensembl API
RUN git ensembl --checkout --branch release/86 api

# Add perl module dependencies for ensembl rest api
# File/Find/Rule required for Devel/CheckOS, which is required by Catalyst
RUN cpanm File::Find::Rule
RUN cpanm Module::Install::AssertOS
RUN cpanm DBI DBD::mysql IO::String 
RUN cpanm Catalyst::Runtime Catalyst::Devel Set::IntervalTree
WORKDIR $HOME/src/ensembl-rest
RUN cpanm --installdeps .

# components of the REST API require the Tabix, HTSlib, and biodbhts libraries
WORKDIR $HOME/src
RUN git clone https://github.com/samtools/tabix
WORKDIR $HOME/src/tabix
RUN make
WORKDIR $HOME/src/tabix/perl
RUN perl Makefile.PL PREFIX=$HOME/src/
RUN make
RUN make install
WORKDIR $HOME/src
RUN git clone https://github.com/samtools/htslib.git
WORKDIR $HOME/src/htslib
RUN make

# It would seem that BioDBHTS supercedes the faidx-xs library
WORKDIR $HOME/src
# BioDBHTS needs to know the location of htslib
ENV HTSLIB_DIR $HOME/src/htslib
RUN export HTSLIB_DIR
RUN git clone https://github.com/Ensembl/Bio-HTS.git biodbhts
WORKDIR $HOME/src/biodbhts
RUN cpanm Module::Build
RUN perl Build.PL
RUN ./Build

# Ensembl claims increase in speed (5-10%) with Ensembl::XS
WORKDIR $HOME/src
RUN git clone https://github.com/Ensembl/ensembl-xs.git
WORKDIR $HOME/src/ensembl-xs
RUN perl Makefile.PL PREFIX=$HOME/src/
RUN make
RUN make install

# add ensembl modules to perl library
ENV PERL5LIB $PERL5LIB:$HOME/src/bioperl-live
ENV PERL5LIB $PERL5LIB:$HOME/src/ensembl/modules
ENV PERL5LIB $PERL5LIB:$HOME/src/ensembl-compara/modules
ENV PERL5LIB $PERL5LIB:$HOME/src/ensembl-funcgen/modules
ENV PERL5LIB $PERL5LIB:$HOME/src/ensembl-variation/modules
ENV PERL5LIB $PERL5LIB:$HOME/src/ensembl-io/modules
ENV PERL5LIB $PERL5LIB:$HOME/src/ensembl-rest/modules
ENV PERL5LIB $PERL5LIB:$HOME/src/ensembl-xs/lib/Bio/EnsEMBL
ENV PERL5LIB $PERL5LIB:$HOME/src/lib/perl/5.18.2
ENV PERL5LIB $PERL5LIB:$HOME/src/tabix/perl
ENV PERL5LIB $PERL5LIB:$HOME/perl5/lib/perl5
ENV PERL5LIB $PERL5LIB:$HOME/src/biodbhts/lib
ENV PERL5LIB $PERL5LIB:$HOME/src/biodbhts/blib/arch/auto/Bio/DB/HTS/Faidx
ENV PERL5LIB $PERL5LIB:$HOME/src/biodbhts/blib/arch/auto/Bio/DB/HTS
RUN export PERL5LIB

# add ensembl tools to path
ENV PATH $HOME/src/ensembl-tools/scripts/assembly_converter:$PATH
ENV PATH $HOME/src/ensembl-tools/scripts/id_history_converter:$PATH
ENV PATH $HOME/src/ensembl-tools/scripts/region_reporter:$PATH
ENV PATH $HOME/src/ensembl-tools/scripts/variant_effect_predictor:$PATH
# add tabix to path
ENV PATH $HOME/src/tabix:$PATH
RUN export PATH

# add config files
COPY ensembl_rest.conf $HOME/src/ensembl-rest/

# add run.sh to convert environment variables
COPY run.sh /usr/bin/

# accept connections over port 3000
EXPOSE 3000

# start rest server
ENTRYPOINT ["/usr/bin/run.sh"]