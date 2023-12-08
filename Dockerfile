# Dockerfile: QTALR Base Image
# About: This Dockerfile replicates the rocker/rstudio image, 
# but specifies versions for RStudio, Pandoc, and Quarto.
# In addition, it installs R packages/ versions for qtalr.

# Use rocker/r-ver as the base image
FROM rocker/r-ver:4.3.1

# Set up environmental variables
ENV S6_VERSION=v2.1.0.2
ENV RSTUDIO_VERSION=2023.06.0+421
ENV DEFAULT_USER=rstudio
ENV PANDOC_VERSION=3.1.1
ENV QUARTO_VERSION=1.3.427 

# Update linux libraries
RUN apt-get update && apt-get install -y build-essential
RUN apt-get install -y libxt-dev

# Install RStudio, Pandoc, and Quarto
RUN /rocker_scripts/install_rstudio.sh
RUN /rocker_scripts/install_pandoc.sh
RUN /rocker_scripts/install_quarto.sh

# Set up user
USER ${DEFAULT_USER}

# Install TinyTex
RUN quarto install tinytex --update-path

# Install common R packages/ version
ENV TIDYVERSE_VERSION=2.0.0
ENV USETHIS_VERSION=2.2.1
ENV RMARKDOWN_VERSION=2.22
ENV TINYTEXT_VERSION=0.45

RUN R -e "install.packages('pak', repos = 'https://cloud.r-project.org')"
CMD R -e "pak::pkg_install(c('tidyverse@${TIDYVERSE_VERSION}', 'usethis@${USETHIS_VERSION}', 'rmarkdown@${RMARKDOWN_VERSION}', 'tinytex@${TINYTEXT_VERSION}'))"


# Copy RStudio preferences
COPY --chown=${DEFAULT_USER}:${DEFAULT_USER} rstudio-prefs.json /home/${DEFAULT_USER}/.config/rstudio/rstudio-prefs.json

# Change back to root user
USER root

# Default port for RStudio
EXPOSE 8787

# Start RStudio
CMD ["/init"]
