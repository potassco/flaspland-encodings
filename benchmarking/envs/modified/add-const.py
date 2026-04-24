import re
import os

directory = "Test_00"

for level in os.listdir(directory):
    level_dir = os.path.join(directory, level)
    if not os.path.isdir(level_dir):
        continue
    for filename in os.listdir(level_dir):
        if not filename.endswith(".lp"):
            continue
        filepath = os.path.join(level_dir, filename)
        with open(filepath, "r") as f:
            content = f.read()
        match = re.search(r"global\((\d+)\)", content)
        if not match:
            continue
        h = match.group(1)
        with open(filepath, "w") as f:
            f.write(f"#const h={h}.\n{content}")