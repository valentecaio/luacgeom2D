#!/usr/bin/python

# Reads JSON data and plots curves, circles, and points using Matplotlib.

import sys
import json
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon

def plot_from_json(json_data):
    plt.clf()

    for obj in json_data['points']:
        label = obj.get('label') # default to None
        color = obj.get('color') # default to None
        plt.plot(obj['x'], obj['y'], 'o', label=label)
    for obj in json_data['curves']:
        label = obj.get('label')
        color = obj.get('color')
        plt.plot(obj['x'], obj['y'], label=label)
    for obj in json_data['polygons']:
        label = obj.get('label')
        color = obj.get('color')
        vertices = obj['vertices']
        polygon = Polygon(vertices, closed=True, fill=False, color=color, label=label)
        plt.gca().add_patch(polygon)
    for obj in json_data['circles']:
        label = obj.get('label')
        color = obj.get('color')
        center = obj['center']
        radius = obj['radius']
        circle = plt.Circle((center['x'], center['y']), radius, color=color, label=label, fill=False)
        plt.gca().add_patch(circle)

    plt.legend()
    plt.xlabel(json_data['xlabel'] if 'xlabel' in json_data else 'X')
    plt.ylabel(json_data['ylabel'] if 'ylabel' in json_data else 'Y')
    plt.title(json_data['title'] if 'title' in json_data else 'MatPlotLua')

    if 'figure' in json_data:
        plt.savefig(json_data["figure"])
    else:
        plt.show()

if __name__ == '__main__':
    if len(sys.argv) == 2:
        # example: python matplotlua.py example.json
        json_filename = sys.argv[1]
        with open(json_filename, 'r') as json_file:
            data = json.load(json_file)
            plot_from_json(data)
    else:
        # if no argument is provided, read JSON data from stdin
        # that's useful for piping data from another program
        # example: cat example.json | python matplotlua.py
        json_data = sys.stdin.read()
        data = json.loads(json_data)
        plot_from_json(data)
