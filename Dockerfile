FROM ca3tech/r-ver:latest

MAINTAINER Clifford Wollam "wollam@ca3tech.com"

# Install dependencies and Download and install shiny server
RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    wget && \
    wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb && \
#    R -e "install.packages(c('shiny', 'rmarkdown'), repos='https://cran.rstudio.com/')" && \
#    cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/ && \
    rm -rf /var/lib/apt/lists/*

### ca3tech additions from here
ARG R_VERSION
ENV R_VERSION ${R_VERSION:-latest}

# Add Linux libraries that may be needed by R packages
RUN apt-get update \
    && apt-get install -y libxml2-dev

# Add shiny libraries to R
RUN . /etc/environment \
    && [ "$R_VERSION" = "latest" ] && REPO="http://cran.rstudio.com/" || REPO=$MRAN \
    &&  Rscript -e "install.packages(c('shiny', 'rmarkdown'), repo = '$REPO')" 
### to here

EXPOSE 3838

COPY shiny-server.sh /usr/bin/shiny-server.sh

CMD ["/usr/bin/shiny-server.sh"]
