import math
from tokenize import group

import matplotlib.pyplot as plt
import numpy as np
from matplotlib.pyplot import bar_label
from numpy.ma.extras import average


def read_file(path):
    with open(path, 'r') as f:
        file = f.read()

    i = file.index(
        "---------------------------------------------------------------------------------------------------")
    e = file.rindex("SPECjvm2008 Version:")
    lines = [l.split() for l in file[i:e].lstrip("-").splitlines() if l != ""]
    return dict([(l[0], float(l[-1])) for l in lines])


def shorten(s: str, group_all: bool) -> str:
    if group_all:
        # if s.startswith("scimark"):
        #     if s.endswith(".small"):
        #         return "scimark.small"
        #     if s.endswith(".large"):
        #         return "scimark.large"
        #     return s
        #     #raise Exception("unexpected: " + s)
        return s.split('.')[0]
    elif s.startswith("startup"):
        return "startup"
    else:
        return s


def geometric_mean(x: list) -> float:
    if len(x) == 1:
        return x[0]
    else:
        a = np.array(x)
        return round(a.prod() ** (1.0 / len(a)), ndigits=2)


def combine(data: dict, group_all: bool):
    combined = {shorten(s, group_all): [] for s in data.keys()}
    for k, v in data.items():
        combined[shorten(k, group_all)].append(v)

    return {k: geometric_mean(v) for k, v in combined.items()}


def flatten(files: list[dict], reverse: bool):
    labels = sorted({k for f in files for k in f.keys()}, reverse=reverse)
    values = zip(*[[f.get(a, float('nan')) for f in files] for a in labels])
    return np.array(labels), map(np.array, values)


def plot3(files: list[dict]):
    labels, (v1, v2, v3) = flatten([combine(f, group_all=False) for f in files], reverse=True)

    fig, ax = plt.subplots(figsize=(8.3, 11.7))
    bar_width = 0.28
    y_pos = np.arange(len(labels))

    b1 = ax.barh(y_pos + bar_width, v1, height=bar_width, label='CACAO OSR')
    b2 = ax.barh(y_pos, v2, height=bar_width, label='CACAO Baseline')
    b3 = ax.barh(y_pos - bar_width, v3, height=bar_width, label='Zulu 7.56.0.11')

    ax.bar_label(b1, padding=3)
    ax.bar_label(b2, padding=3)
    ax.bar_label(b3, padding=3)
    ax.margins(x=0.14)  # to prevent labels from going outside the plot

    for i, val in enumerate(v1):
        if math.isnan(val):
            ax.text(10, i + bar_width, 'N/A', va='center', ha='left')

    ax.set_ylim(min(y_pos) - 2 * bar_width, max(y_pos) + 2 * bar_width)

    ax.set_yticks(y_pos)

    ax.set_yticklabels(labels)
    ax.set_xlabel('ops/m')
    ax.set_title('SpecJVM2008 Scores')
    ax.legend(loc='upper right', bbox_to_anchor=(1.0, 0.1))

    plt.tight_layout()
    plt.savefig('plots/plot3.pdf')
    plt.close()


def plot3_grouped(files: list[dict]):
    print("grouped", [combine(f, group_all=True) for f in files][0])

    labels, (v1, v2, v3) = flatten([combine(f, group_all=True) for f in files], reverse=True)

    fig, ax = plt.subplots(figsize=(8.3, 11.7 / 2))
    bar_width = 0.28
    y_pos = np.arange(len(labels))

    b1 = ax.barh(y_pos + bar_width, v1, height=bar_width, label='CACAO OSR')
    b2 = ax.barh(y_pos, v2, height=bar_width, label='CACAO Baseline')
    b3 = ax.barh(y_pos - bar_width, v3, height=bar_width, label='Zulu 7.56.0.11')

    ax.bar_label(b1, padding=3)
    ax.bar_label(b2, padding=3)
    ax.bar_label(b3, padding=3)
    ax.margins(x=0.09)  # to prevent labels from going outside the plot

    for i, val in enumerate(v1):
        if math.isnan(val):
            ax.text(10, i + bar_width, 'N/A', va='center', ha='left')

    ax.set_ylim(min(y_pos) - 2 * bar_width, max(y_pos) + 2 * bar_width)

    ax.set_yticks(y_pos)

    ax.set_yticklabels(labels)
    ax.set_xlabel('ops/m, geometric mean of sub-benchmarks')
    ax.set_title('SpecJVM2008 Scores')
    ax.legend(loc='upper right')

    plt.tight_layout()
    plt.savefig('plots/plot3_grouped.pdf')
    plt.close()


def plot_normalized(files, grouped):
    labels, (v1, v2, v3) = flatten([combine(f, group_all=grouped) for f in files], reverse=True)

    v1 = np.array(v1)
    v2 = np.array(v2)

    n = np.round((v1 / v2) * 100.0, decimals=2)

    fig, ax = plt.subplots(figsize=(8.3, 5.8))

    b = ax.barh(labels, n)
    ax.bar_label(b, padding=3)
    ax.margins(x=0.1)  # to prevent labels from going outside the plot

    for i, val in enumerate(n):
        if math.isnan(val):
            ax.text(1.2, i, 'N/A', va='center', ha='left')

    ax.set_ylim(-0.5, len(labels) - 0.5)

    # ax.axvline(x=np.nanmean(n), color='green', linestyle='--', linewidth=2)
    ax.axvline(x=100, color='green', linestyle='--', linewidth=2)
    ax.set_xlabel('percentage of ops/m relative to baseline')
    ax.set_title('SpecJVM2008 Score with OSR relative to Baseline')

    plt.tight_layout()
    if grouped:
        plt.savefig('plots/plot_normalized_grouped.pdf')
    else:
        plt.savefig('plots/plot_normalized.pdf')
    plt.close()


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    files = [
        read_file("results/SPECjvm2008.001/SPECjvm2008.001.txt"),
        read_file("results/SPECjvm2008.002/SPECjvm2008.002.txt"),
        read_file("results/SPECjvm2008.003/SPECjvm2008.003.txt"),
    ]
    keys = {k for f in files for k in f.keys()}
    for f in files:
        for k in keys:
            if not k in f:
                f[k] = float('nan')

    plot3(files)
    plot3_grouped(files)
    plot_normalized(files, grouped=False)
    plot_normalized(files, grouped=True)
