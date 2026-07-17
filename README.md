# SwissRN Workshop on Computational Reproducibility

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg?style=flat-square)](https://creativecommons.org/licenses/by/4.0/)
![R](https://img.shields.io/badge/R-276DC3?style=flat-square&logo=r&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=flat-square&logo=python&logoColor=white)
![Quarto](https://img.shields.io/badge/Quarto-39729E?style=flat-square&logo=quarto&logoColor=white)
![LaTeX](https://img.shields.io/badge/LaTeX-008080?style=flat-square&logo=latex&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker&logoColor=white)
![Snakemake](https://img.shields.io/badge/Snakemake-039475?style=flat-square)
![Nextflow](https://img.shields.io/badge/Nextflow-0DC09D?style=flat-square&logo=nextflow&logoColor=white)

Part of the [OPeR-RA workshop series](https://www.swissrn.org/contents/activities/operra/).

As part of this workshop you will fork this repository and turn it into a small
but complete reproducible project: a dynamic report generated from real data, an
analysis pipeline you run end to end, the container it all runs inside, and a
published archive with its own DOI.

**No prior experience with Git, Docker, Snakemake or Nextflow is expected.** Having seen some R or Python before helps in Module 2, but the exercises are written to be followed without it. The workshop environment runs in your browser, so there is nothing to install.

The website for this workshop is: <https://crsuzh.pages.uzh.ch/operra-reproducibility>

## Modules

0. [**Introduction**](https://crsuzh.pages.uzh.ch/operra-reproducibility/module_0_introduction/slides/): What computational reproducibility is and why it matters
1. [**Version Control**](https://crsuzh.pages.uzh.ch/operra-reproducibility/module_1_version_control/slides/): Git and version control
2. [**Dynamic Reporting**](https://crsuzh.pages.uzh.ch/operra-reproducibility/module_2_dynamic_reporting/slides/): Writing reports where code and prose live together
3. [**Workflow Management**](https://crsuzh.pages.uzh.ch/operra-reproducibility/module_3_workflow_management/slides/): Chaining analysis steps into a reproducible pipeline
4. [**Software Containers**](https://crsuzh.pages.uzh.ch/operra-reproducibility/module_4_containers/slides/): Docker and containerising an analysis
5. [**Sharing & Publishing**](https://crsuzh.pages.uzh.ch/operra-reproducibility/module_5_sharing_publishing/slides/): Archiving, licensing and publishing reproducible work

Each module pairs a short presentation with a hands-on exercise. Start with the
[Instructions](https://crsuzh.pages.uzh.ch/operra-reproducibility/instructions/)
page to set up your environment before the workshop begins.

## Getting Started

<details open>
<summary><strong>Option 1: Open in GitHub Codespaces</strong> (recommended)</summary>

<br>

- Fork this repository to your account: <https://github.com/a1eksb/operra-reproducibility>

- Create a new codespace.
  1. Select the forked repository.
  2. Select `Dev container configuration` as "Operra - RStudio (project-wide)"
  3. Create codespace (this may take several minutes)

    ![Creating a codespace: open Code → Codespaces → Codespace repository configuration, set Dev container configuration to "Operra - RStudio (project-wide)", then Create codespace](contents/assets/creating-codespaces.gif)

- Navigate to `Ports` and open the provided URL in a new tab

- When you are finished, stop or delete the codespace so it does not keep consuming your free monthly quota.
  1. Open `Code` → `Codespaces`
  2. Use the `...` menu next to your codespace:
  3. **Stop** keeps your work for later, while
  4. **Delete** removes the codespace and any uncommitted changes in it.

    ![Stopping and deleting a codespace: open Code → Codespaces, then use the ... menu next to the codespace to select Stop or Delete](contents/assets/stopping-deleting-codespaces.gif)

</details>

<details>
<summary><strong>Option 2: Running Locally via Docker</strong></summary>

<br>

#### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/) installed

#### Option A — Docker Compose (recommended)

Clone the repository, then build the image locally and mount the project directory:

```bash
docker compose build pyverse --no-cache
docker compose up -d
```

Open RStudio Server at [http://localhost:8787](http://localhost:8787) — no login required.

To stop:

```bash
docker compose down
```

#### Option B — Build and run manually

Build the image locally:

```bash
docker build -t pyverse .
```

Run with the project directory mounted:

```bash
docker run --rm -d \
  -p 127.0.0.1:8787:8787 \
  -e DISABLE_AUTH=true \
  -e USER=rstudio \
  -v "$(pwd)":/home/rstudio/project \
  pyverse
```

Open RStudio Server at [http://localhost:8787](http://localhost:8787) — no login required.

> **Note:** RStudio is bound to `127.0.0.1` only, so it is not accessible from other machines on your network.

</details>

## Repository structure

`contents/` holds both halves of the workshop: the slides, and the hands-on
material. Everything outside `contents/` exists to give
you an environment those examples run in, or to publish the site.


```
operra-reproducibility/
├── contents/                        # Slides + runnable material
│   ├── _quarto.yml                  # Website config: navbar, modules, theme, render rules
│   ├── index.qmd                    # Website landing page with the module overview
│   ├── assets/                      # Logos and the favicon used across the site
│   ├── instructions/                # Setup to complete *before* the workshop starts
│   │
│   ├── module_0_introduction/       # What computational reproducibility is and why it matters
│   │   └── slides/                  # Slides only — no exercise for this module
│   │
│   ├── module_1_version_control/    # Git and version control
│   │   ├── slides/
│   │   └── demo/                    # Exercise: edit the README, commit, push, resolve a conflict
│   │
│   ├── module_2_dynamic_reporting/  # Writing reports where code and prose live together
│   │   ├── slides/
│   │   ├── demo_R/                  # Live R analysis of a real Zurich first-names dataset
│   │   └── demo_py/                 # The same analysis in Python
│   │
│   ├── module_3_workflow_management/# Chaining analysis steps into a reproducible pipeline
│   │   ├── slides/
│   │   └── demo/
│   │       ├── index.qmd            # Exercise instructions tying the two pipelines together
│   │       ├── snakemake/           # Complete runnable Snakemake pipeline
│   │       └── nextflow/            # The same pipeline in Nextflow
│   │
│   ├── module_4_containers/         # Docker and containerising an analysis
│   │   ├── slides/
│   │   └── demo/                    # Exercise: dissect this repo's own Dockerfile line by line
│   │
│   └── module_5_sharing_publishing/ # Archiving, licensing and publishing reproducible work
│       ├── slides/
│       └── demo/                    # Exercise: publish a release and mint a Zenodo DOI
│
├── .devcontainer/                   # Codespaces dev container settings
├── .github/workflows/               # GitHub Actions that build and publish the workshop docker image
├── .gitlab-ci.yml                   # GitLab CI job that renders the site and deploys it to Pages
├── Dockerfile                       # Workshop dockerfile that defines the image: R + Python + Quarto, Snakemake and Nextflow
├── docker-compose.yaml              # Runs that image as RStudio Server on localhost:8787
├── .dockerignore                    # Limits the Docker build context to Dockerfile + requirements
├── requirements.txt                 # Pinned Python packages installed into the image and CI
├── workshop-operra.Rproj            # RStudio project file that opens the repository root
├── LICENSE                          # CC BY 4.0 licence covering the workshop material
└── README.md                        # This file: setup instructions and repository overview
```

## Citation

Cite this workshop as:

A BibTeX entry is given by:
