FROM ubuntu:20.04
# FROM python:3.9.9-buster

# ENV
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin
ENV LC_ALL=C
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update
RUN apt-get install -y software-properties-common

# R 4.1.2
RUN gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN gpg -a --export E298A3A825C0D65DFD57CBB651716619E084DAB9 | apt-key add -
RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/'
RUN apt-get update
RUN apt-get install -y r-base r-base-core \
                       libcurl4-openssl-dev libssl-dev libxml2-dev
RUN Rscript -e "install.packages(c('data.table', 'R.utils', 'devtools'))"

# ManQQ
RUN Rscript -e "library(devtools); install_github('hmgu-itg/man_qq_annotate@v0.2.3')"

# Python 3.8.10
RUN apt-get update
RUN apt-get install -y python3-dev python3-pip
RUN python3 -m pip install matplotlib numpy pandas seaborn requests CrossMap rpy2

# Plink
RUN apt-get install -y wget
RUN wget https://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20210606.zip && unzip plink_linux_x86_64_20210606.zip && rm prettify toy.* LICENSE && mv plink /usr/local/bin/plink
RUN wget https://s3.amazonaws.com/plink2-assets/plink2_linux_avx2_20211011.zip && unzip plink2_linux_avx2_20211011.zip && mv plink2 /usr/local/bin/plink2
RUN chmod -R 755 /usr/local/bin

ENV PATH="/usr/local/bin:${PATH}"


# MyBinder specifics
RUN python3 -m pip install --no-cache-dir notebook jupyterlab

RUN Rscript -e "install.packages('IRkernel', repos='https://cran.rstudio.com'); IRkernel::installspec(name = 'ir41', displayname = 'R 4.1', user = FALSE)" # This one is mine

ARG NB_USER=user
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}


# Data
WORKDIR $HOME
RUN wget https://ftp.ebi.ac.uk/pub/databases/spot/pgs/scores/PGS000337/ScoringFiles/PGS000337.txt.gz
RUN wget https://www.dropbox.com/s/o71gg622t2vnjqu/MEP1B.gilly.prs.txt?dl=1 -O MEP1B.gilly.prs.txt
RUN wget -O PRS.course.forscore.tar.gz https://www.dropbox.com/s/civmjfv89ou72cc/PRS.course.forscore.tar.gz?dl=1 && tar -xvzf PRS.course.forscore.tar.gz
RUN wget -O PRS.course.geno.tar.gz https://www.dropbox.com/s/oml7xw36yse7lld/PRS.course.geno.tar.gz?dl=1 && tar -xvzf PRS.course.geno.tar.gz
RUN wget -O CAD.phenotype https://www.dropbox.com/s/xs7wsgij95w2uau/CAD.phenotype?dl=1
RUN wget -O MEP1B.phenotype https://www.dropbox.com/s/5rmhjmv0d6oqxpr/MEP1B.phenotype?dl=1
RUN wget -O PCs.eigenvec https://www.dropbox.com/s/5phdnh9st0p5dah/PCs.eigenvec?dl=1