import os
import sys
# Get the sample filename from arguments
sample_filename = sys.argv[1]

# Split the sample filename at the first occurrence of '__'
directory_name = sample_filename.split('__')[0]

# Create the directory if it doesn't exist
os.makedirs(directory_name, exist_ok=True)
print(directory_name)
