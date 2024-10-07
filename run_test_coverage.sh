#!/bin/bash

# Script to clean coverage folder and run test coverage

# Check if coverage directory exists
if [ -d "coverage" ]; then
    echo "Removing existing coverage directory..."
    rm -rf coverage
    echo "Coverage directory removed."
else
    echo "No existing coverage directory found."
fi

# Run melos test_coverage command
echo "Running melos test_coverage..."
melos test_coverage

echo "Test coverage completed."
