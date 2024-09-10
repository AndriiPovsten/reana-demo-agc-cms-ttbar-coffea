import os
import sys
# Create the sample name directory folder structure
sample_filename = sys.argv[1]
#Split the sample filename to remove everything after the second-to-last underscore
directory_name = '_'.join(sample_filename.split('_')[:-1])

# Create the directory if it is not existing
os.makedirs(directory_name, exist_ok=True)

print(f"Directory structure created for: {directory_name}")
