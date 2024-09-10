import glob
import json
import os
#Funtion to extract samples from input JSON file and generate necessary .txt files
N_FILES_MAX_PER_SAMPLE = config["file_number"]
def extract_samples_from_json(json_file):
    output_files = []
    with open(json_file, "r") as fd:
        data = json.load(fd)
        for sample, conditions in data.items():
            for condition, details in conditions.items():
                #Creating a filename for the file and condition
                sample_name = f"{sample}__{condition}"
                output_files.append((sample, condition))
                # Write paths to a .txt file with the correct path replacement
                with open(f"sample_{sample_name}_paths.txt", "w") as path_file:
                    paths = [file_info["path"] for file_info in details["files"]]
                    path_file.write("\n".join(paths))
                    paths = [
                        file_info["path"].replace(
                            "https://xrootd-local.unl.edu:1094//store/user/AGC/nanoAOD",
                            "root://eospublic.cern.ch//eos/opendata/cms/upload/agc/1.0.0/"
                        )
                        for file_info in details["files"]
                    ]
    return output_files
#Function to get file paths based on the index
def get_file_paths(wildcards, max=N_FILES_MAX_PER_SAMPLE):
    "Return list of at most MAX file paths for the given SAMPLE and CONDITION."
    filepaths = []
    with open(f"sample_{wildcards.sample}__{wildcards.condition}_paths.txt", "r") as fd:
        filepaths = fd.read().splitlines()
    # Using the index as the wildcard, creating a path for each file based on it's index
    return [f"histograms/histograms_{wildcards.sample}__{wildcards.condition}__{index}.root" for index in range(len(filepaths))][:max]

samples_conditions = extract_samples_from_json(config["input_file"])

rule all:
    input:
        config["output_file"]

rule process_sample_one_file_in_sample:
    container:
        "povstenandrii/ttbarkerberos:20240311"
        #"docker.io/reanahub/reana-demo-agc-cms-ttbar-coffea:1.0.0"
    resources:
        kubernetes_memory_limit="1850Mi"
    input:
        notebook=config["notebook"]
    output:
        "histograms/histograms_{sample}__{condition}__{index}.root"
    params:
        sample_name = '{sample}__{condition}'
    shell:
        "/bin/bash -l && source fix-env.sh && python prepare_workspace.py sample_{params.sample_name}_{wildcards.index} && papermill {input.notebook} sample_{params.sample_name}_{wildcards.index}_out.ipynb -p"
        "sample_name {params.sample_name} -p index {wildcards.index} -k python3"

rule process_sample:
    container:
        "povstenandrii/ttbarkerberos:20240311"
        #"docker.io/reanahub/reana-demo-agc-cms-ttbar-coffea:1.0.0"
    resources:
        kubernetes_memory_limit="1850Mi"
    input:
        "file_merging.ipynb",
        get_file_paths
    output:
        "everything_merged_{sample}__{condition}.root"
    params:
        sample_name = '{sample}__{condition}'
    shell:
        "/bin/bash -l && source fix-env.sh && papermill file_merging.ipynb merged_{params.sample_name}.ipynb -p sample_name {params.sample_name} -k python3"

rule merging_histograms:
    container:
        "povstenandrii/ttbarkerberos:20240311"
        #"docker.io/reanahub/reana-demo-agc-cms-ttbar-coffea:1.0.0"
    resources:
        kubernetes_memory_limit="1850Mi"
    input:
        "everything_merged_ttbar__nominal.root",
        "everything_merged_ttbar__ME_var.root",
        "everything_merged_ttbar__PS_var.root",
        "everything_merged_ttbar__scaleup.root",
        "everything_merged_ttbar__scaledown.root",
        "everything_merged_single_top_s_chan__nominal.root",
        "everything_merged_single_top_t_chan__nominal.root",
        "everything_merged_single_top_tW__nominal.root",
        "everything_merged_wjets__nominal.root",
        notebook=config["final_merging"]
    output:
        output_file=config["output_file"]
    shell:
        "/bin/bash -l && source fix-env.sh && papermill {input.notebook} result_notebook.ipynb -k python3"

    