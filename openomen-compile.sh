# Activate venv
echo "[INFO] Activating virtual environment..."
python3 -m venv .venv
source .venv/bin/activate

# Prepare venv
echo "[INFO] Preparing virtual environment..."
python -m pip install --upgrade pip > /dev/null
pip install pyinstaller > /dev/null

# Build
echo "[INFO] Compiling..."
pyinstaller openomen.spec > /dev/null 2>&1

# Clean
echo "[INFO] Cleaning up..."
mv dist/openomen openomen_exec
rm -rf build dist .venv

# Run
clear
echo "[INFO] Compilation complete."
source ~/.bashrc
./openomen_exec -v
echo "[INFO] Done."