import pandas as pd
import json
import ast
import sys
import os

# Add student_workspace to path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from student_workspace import solution

# === Validations ===
def validate_columns(df, expected_cols):
    assert list(df.columns) == expected_cols, f"❌ Columns mismatch: {list(df.columns)} != {expected_cols}"

def validate_row_count(df, expected_rows):
    assert len(df) == expected_rows, f"❌ Expected {expected_rows} rows, got {len(df)}"

def check_no_hardcoding(func_name):
    with open("student_workspace/solution.py", "r") as f:
        tree = ast.parse(f.read())

    for node in ast.walk(tree):
        if isinstance(node, ast.FunctionDef) and node.name == func_name:
            for child in ast.walk(node):
                if isinstance(child, ast.Return):
                    if isinstance(child.value, (ast.List, ast.Tuple, ast.Dict, ast.Str, ast.Constant)):
                        raise Exception(f"🚫 Hardcoded return detected in function: {func_name}")

def check_required_functions():
    required = ['groupby', 'agg', 'merge', 'mean']
    used = set()

    with open("student_workspace/solution.py", "r") as f:
        tree = ast.parse(f.read())

    for node in ast.walk(tree):
        if isinstance(node, ast.Call) and isinstance(node.func, ast.Attribute):
            used.add(node.func.attr)

    missing = [f for f in required if f not in used]
    if missing:
        raise Exception(f"🚫 Required Pandas functions not used: {missing}")

# === Run Tests ===
# Validate function usage first
check_required_functions()

# Load test config
with open("test_config.json") as f:
    config = json.load(f)

# Preload DataFrames
players = solution.load_players("data/players.csv")
matches = solution.load_matches("data/matches.csv")
merged = solution.merge_players_matches(players, matches)

# Test each function
for test in config['tests']:
    func_name = test['function']
    func = getattr(solution, func_name)

    print(f"\n🧪 Running: {func_name}...")

    # Choose input
    if func_name == "merge_players_matches":
        df = func(players, matches)
    elif func_name == "load_players":
        df = func("data/players.csv")
    elif func_name == "load_matches":
        df = func("data/matches.csv")
    else:
        df = func(
            merged if test['input'] == 'merged'
            else players if test['input'] == 'players'
            else matches
        )

    # Validate output
    if 'expected_columns' in test:
        validate_columns(df, test['expected_columns'])

    if 'expected_rows' in test:
        validate_row_count(df, test['expected_rows'])

    # Check for hardcoding
    check_no_hardcoding(func_name)

    print(f"✅ Passed: {func_name}")

print("\n🎉 All tests passed successfully!")
