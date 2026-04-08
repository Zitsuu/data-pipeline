"""Start a Prefect worker for the default-pool.

Run this in a dedicated terminal:
    python -m scripts.start_worker

Or equivalently:
    prefect worker start --pool default-pool
"""

import subprocess
import sys


def main():
    subprocess.run(
        [sys.executable, "-m", "prefect", "worker", "start", "--pool", "default-pool"],
        cwd=".",
    )


if __name__ == "__main__":
    main()
