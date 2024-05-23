import subprocess
import time

def run_ansible_playbook(playbook, inventory, iteration):
    start_time = time.time()
    
    print(f"Running Ansible playbook iteration {iteration}")
    result = subprocess.run(
        ["ansible-playbook", "-i", inventory, playbook],
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
    playbook = "install_nginx.yml"
    inventory = "inventory.ini"

    for i in range(1, 4):  # Run a few iterations to test
        run_ansible_playbook(playbook, inventory, i)
