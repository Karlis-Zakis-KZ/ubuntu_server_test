import subprocess
import time

def run_puppet_bolt_plan(plan, inventory, targets, iteration):
    start_time = time.time()
    
    print(f"Running Puppet Bolt plan iteration {iteration}")
    result = subprocess.run(
        ["bolt", "plan", "run", plan, "--targets", targets, "--inventoryfile", inventory],
        capture_output=True,
        text=True
    )
    
    end_time = time.time()
    duration = end_time - start_time

    print(f"Iteration {iteration} completed in {duration:.2f} seconds")
    print("STDOUT:", result.stdout)
    print("STDERR:", result.stderr)
    return duration

if __name__ == "__main__":
    plan = "simple_puppet_bolt::install_nginx"
    inventory = "inventory.yaml"
    targets = "192.168.21.138"

    for i in range(1, 4):  # Run a few iterations to test
        run_puppet_bolt_plan(plan, inventory, targets, i)
