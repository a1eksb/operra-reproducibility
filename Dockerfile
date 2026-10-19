# Builds the workshop's RStudio docker image with its R and Python dependencies.
FROM rocker/verse:4.5.0@sha256:de5869209b7073456dbdd4a096f7d1decf9242a7a977279b66396f4ea5660aa3

RUN install2.r kableExtra && \
    apt-get update && apt-get install -y --no-install-recommends \
    python3-venv \
    graphviz \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir -r requirements.txt && \
    chown -R rstudio:rstudio /opt/venv

ENV PATH=/opt/venv/bin:$PATH

EXPOSE 8787
ENV USER=rstudio
CMD ["/init"]
