FROM rocker/verse:4.5.0

ARG NEXTFLOW_VERSION=26.04.0

RUN install2.r kableExtra && \
    apt-get update && apt-get install -y --no-install-recommends \
    python3-pip \
    python3-venv \
    openjdk-21-jre-headless \
    graphviz \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir -r requirements.txt && \
    NXF_VER=${NEXTFLOW_VERSION} curl -s https://get.nextflow.io | bash && mv nextflow /usr/local/bin/ && \
    chown -R rstudio:rstudio /opt/venv

ENV PATH=/opt/venv/bin:$PATH
ENV NXF_VER=${NEXTFLOW_VERSION}

EXPOSE 8787
ENV USER=rstudio
CMD ["/init"]
