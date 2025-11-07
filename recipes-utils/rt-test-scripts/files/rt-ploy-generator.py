#!/usr/bin/env python3

# ##################################################################################
# Copyright (C) 2025 Altera Corporation
#
# This software and the related documents are Altera copyrighted materials, and
# your use of them is governed by the express license under which they were
# provided to you ("License"). Unless the License provides otherwise, you may
# not use, modify, copy, publish, distribute, disclose or transmit this software
# or the related documents without Altera's prior written permission.
#
# This software and the related documents are provided as is, with no express
# or implied warranties, other than those that are expressly stated in the License.
# ##################################################################################

import os
import pandas as pd
import matplotlib.pyplot as plt
import io

def process_file(file_path):
    # Extract the name part from the file name
    name = os.path.basename(file_path).split('_', 1)[1]

    # Initialize lists to store max and avg latencies per core
    max_latencies = []
    avg_latencies = []

    # Read the file and extract maximum and average latencies
    with open(file_path, 'r') as file:
        lines = file.readlines()
        for line in lines:
            if "Max Latencies" in line:
                # Extract numeric values from the line
                max_latency_values = [int(value) for value in line.split() if value.isdigit()]
                max_latencies.extend(max_latency_values)
            elif "Avg Latencies" in line:
                # Extract numeric values from the line
                avg_latency_values = [float(value) for value in line.split() if value.replace('.', '', 1).isdigit()]
                avg_latencies.extend(avg_latency_values)

    # Read data lines, remove empty lines, and create a DataFrame
    data_lines = [line for line in lines if not line.startswith('#') and line.strip()]
    if data_lines:
        data = pd.read_csv(io.StringIO('\n'.join(data_lines)), sep='\s+', header=None)

        # Detect the number of cores based on the number of columns in the data
        cores = data.shape[1] - 1

        # Create two-column data sets with latency classes and frequency values for each core
        histograms = []
        for i in range(1, cores + 1):
            histograms.append(data[[0, i]])

        # Plot the data
        plt.figure(figsize=(10, 6))
        plt.title(f"Latency plot for {name}")
        plt.xlabel("Latency (us)")
        plt.ylabel("Number of latency samples")
        plt.xscale('linear')
        plt.yscale('log')
        plt.xlim(0, 400)

        # Set y-axis limits based on the data
        y_min = min(histogram[i + 1].min() for i, histogram in enumerate(histograms))
        y_max = max(histogram[i + 1].max() for i, histogram in enumerate(histograms))
        plt.ylim(y_min if y_min > 0 else 0.8, y_max)

        for i, histogram in enumerate(histograms):
            plt.step(histogram[0], histogram[i + 1], where='mid', label=f'CPU{i} Max: {max_latencies[i]} us, Avg: {avg_latencies[i]:.2f} us')

        plt.legend()
        plot_path = os.path.join(os.path.dirname(file_path), f'plot_{name}.png')
        plt.savefig(plot_path)
        plt.close()
    else:
        print(f"No valid data found in {file_path}")

def traverse_and_plot(root_dir):
    for dirpath, _, filenames in os.walk(root_dir):
        for filename in filenames:
            if filename.startswith('output_'):
                file_path = os.path.join(dirpath, filename)
                process_file(file_path)

if __name__ == "__main__":
    traverse_and_plot('.')
