### REANA example - AGC CMS ttbar analysis with Coffea

This `REANA <http://www.reana.io/>`_ reproducible analysis example demonstrates
a `AGC <https://arxiv.org/abs/1010.2506>`

### Analysis Grand Challenge

For full explanation please have a look at this documentation:
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.7274936.svg)](https://doi.org/10.5281/zenodo.7274936)
[![Documentation Status](https://readthedocs.org/projects/agc/badge/?version=latest)](https://agc.readthedocs.io/en/latest/?badge=latest)

The Analysis Grand Challenge (AGC) is about performing the last steps in an analysis pipeline at scale to test workflows envisioned for the HL-LHC.
This includes

- columnar data extraction from large datasets,
- processing of that data (event filtering, construction of observables, evaluation of systematic uncertainties) into histograms,
- statistical model construction and statistical inference,
- relevant visualizations for these steps,

The physics analysis task is a $t\bar{t}$ cross-section measurement with 2015 CMS Open Data (see `datasets/cms-open-data-2015`).
The current reference implementation can be found in `analyses/cms-open-data-ttbar`.


Please see the `REANA-Client <https://reana-client.readthedocs.io/>`_
documentation for more detailed explanation of typical ``reana-client`` usage

We start by creating a `reana.yaml <reana.yaml>`_ file describing the above
analysis structure with its inputs, code, runtime environment, computational
workflow steps and expected outputs:

### 1. Input data for ``reana-snakemake.yaml`` 
This file describes the above analysisc structure with its inputs, code, runtime environment, computational workflow steps and expected outputs.

The analysis takes the following inputs:

- ``nanoAODschema.json`` input `.root` files
- ``Snakefile(EOS)`` The Snakefile for `root://eospublic.cern.ch//eos/opendata/cms/upload/agc/1.0.0/` url.
- ``Snakefile(UNL)`` The Snakefile for `https://xrootd-local.unl.edu:1094//store/user/AGC/nanoAOD` url. 
- ``ttbar_analysis_reana.ipynb`` The main notebook file where files are processed and analysed.
- ``file_merging.ipynb`` Notebook of merging file for sample   
- ``final_merging.ipynb`` Notebook for merging histograms together all of 

### 2. Compute environment 

We are using the modified verison of the ``analysis-systems-base`` [Docker image](https://github.com/iris-hep/analysis-systems-base) container with additional packages, the main on is [papermill](https://papermill.readthedocs.io/en/latest/) which allows to run the Jupyter Notebook from the commad line with additional parameters.

### 3. Snakemake multicascading
REANA provide a support of Snakemake workflow engine support.
In order to receive the fastest execution of all workflow, we split the original analysis into 2 level (multicascading) paralelisation with Snakemake.
At first step Snakemake submits all of the jobs in the separate nodes with single `.root` file for 1 notebook
Firsly, we made a paralelisation over the each root file in the each Snakemake rule.
After each rule the merging of each file into one file for sample is happening  

          ttbar_1    ttbar_2  ttbar_3 ...        wjets_1   wjets_2   wjets_3 ...

              \        |      /                      \      |       /
               \       |     /                        \     |      /

                merge ttbar_nominal                  merge wjets_nominal

                         \                                /
                          \                              /

                                   merge all samples

                                          |
                                          |

                                  histogram_merged.root


### 4. Nodes Tests

Here is the tests where you can see the time for run of each running, pending and finishing job.


### 5. Output results

The output is created under the name of ``histograms_merged.root`` which can be further evaluated with variety of AGC tools.

### Future goals

The last step would be to add the posibility to make the whole workflow recastable with the RECAST platform which can add the new sample with new files.

