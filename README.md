### REANA example - AGC CMS ttbar analysis with Coffea

This `[REANA](<http://www.reana.io/>)`_ reproducible analysis example demonstrates
a `[AGC](<https://arxiv.org/abs/1010.2506>)` - Analysis Grand Challenge.

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


Please see the `[REANA-Client] (<https://reana-client.readthedocs.io/>)`_
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
- ``file_merging.ipynb`` Notebook to merge each processed `.root` file in one file with unique keys.
- ``final_merging.ipynb`` Notebook to merge histograms together all of 

### 2. Compute environment 

We are using the modified verison of the ``analysis-systems-base`` [Docker image](https://github.com/iris-hep/analysis-systems-base) container with additional packages, the main on is [papermill](https://papermill.readthedocs.io/en/latest/) which allows to run the Jupyter Notebook from the command line with additional parameters.

### 3. Snakemake multicascading
REANA provides support for the Snakemake workflow engine. To ensure the fastest execution of the AGC ttbar workflow, a two-level (multicascading) parallelization approach with Snakemake is implemented.
In the initial step, Snakemake distributes all jobs across separate nodes, each with a single `.root` file for `ttbar_analysis_reana.ipynb`. 
Subsequently, after the completion of each rule, the merging of individual files into one per sample takes place.

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
Which will be added up soon.

### 5. Output results

The output is created under the name of ``histograms_merged.root`` which can be further evaluated with variety of AGC tools.

### Future goals
The final step involves integrating the capability to make the entire workflow adaptable with the RECAST platform. This integration allows for the addition of new samples along with their associated files. This addition won't disrupt the overall workflow; instead, it will seamlessly merge the results into the final ``histograms_merged.root`` file.





