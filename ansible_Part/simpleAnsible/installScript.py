import subprocess
import time
from scapy.all import sniff, wrpcap

def run_ansible_playbook(playbook, inventory):
    start_time = time.time()
    
    # Start sniffing packets
    packets = sniff(timeout=60)  # Adjust timeout based on expected duration
    
    # Run the Ansible playbook
    result = subprocess.run(
        ["ansible-playbook", "-i", inventory, playbook],
        capture_output=True,
        text=True
    )
    
    end_time = time.time()
    duration = end_time - start_time

    # Save captured packets to a file
    wrpcap("ansible_install_packets.pcap", packets)

    return result.stdout, result.stderr, duration

if __name__ == "__main__":
    playbook = "install_nginx.yml"
    inventory = "inventory.ini"
    stdout, stderr, duration = run_ansible_playbook(playbook, inventory)

    print("STDOUT:", stdout)
    print("STDERR:", stderr)
    print("Duration:", duration, "seconds")
