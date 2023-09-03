# Reads JSON data and plots curves, circles, and points using Matplotlib.

import sys
import json
import matplotlib.pyplot as plt

def plot_from_json(json_data):
    for obj in json_data:
        obj_type = obj['type'] # mandatory
        label = obj.get('label') # default to None
        color = obj.get('color') # default to None
        if obj_type == 'point':
            plt.plot(obj['x'], obj['y'], 'o', label=label)
        elif obj_type == 'curve':
            plt.plot(obj['x'], obj['y'], label=label)
        elif obj_type == 'circle':
            center = obj['center']
            radius = obj['radius']
            circle = plt.Circle((center['x'], center['y']), radius, color=color, label=label, fill=False)
            plt.gca().add_patch(circle)

    plt.legend()
    plt.xlabel('X')
    plt.ylabel('Y')
    plt.title('MatPlotLua')
    plt.show()

if __name__ == '__main__':
    if len(sys.argv) == 2:
        json_filename = sys.argv[1]
        with open(json_filename, 'r') as json_file:
            data = json.load(json_file)
            plot_from_json(data)
    else:
        # if no argument is provided, read JSON data from stdin
        # that's useful for piping data from another program
        # example: cat matplotlua.json | python matplotlua.py
        json_data = sys.stdin.read()
        data = json.loads(json_data)
        plot_from_json(data)
