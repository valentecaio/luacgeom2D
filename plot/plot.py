# plot.py
# Reads JSON data from a file or stdin and plots curves, circles, and points using Matplotlib.

import sys
import json
import matplotlib.pyplot as plt

def plot_from_json(data):
    for item in data:
        item_type = item.get('type')

        if item_type == "curve":
            x = item.get('x', [])
            y = item.get('y', [])
            plt.plot(x, y, label='Curve')

        elif item_type == "circle":
            center = item.get('center')
            radius = item.get('radius')
            circle = plt.Circle((center['x'], center['y']), radius, color='r', fill=False)
            plt.gca().add_patch(circle)
            plt.scatter(center['x'], center['y'], color='r', label='Circle Center')

        elif item_type == "point":
            x = item.get('x', [])
            y = item.get('y', [])
            plt.scatter(x, y, label='Points')

    plt.xlabel('X')
    plt.ylabel('Y')
    plt.title('JSON Data Plot')
    plt.legend()
    plt.show()

if __name__ == '__main__':
    if len(sys.argv) == 2:
        # If a command-line argument is provided, assume it's a JSON filename
        json_filename = sys.argv[1]
        with open(json_filename, 'r') as json_file:
            data = json.load(json_file)
            plot_from_json(data)
    else:
        # If no argument is provided, read JSON data from stdin
        json_data = sys.stdin.read()
        data = json.loads(json_data)
        plot_from_json(data)
