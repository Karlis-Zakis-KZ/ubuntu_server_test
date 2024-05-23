import subprocess
import time
from scapy.all import sniff, wrpcap

def run_ansible_playbook(playbook, inventory, iteration):
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
    pcap_file = f"ansible_packets_{iteration}.pcap"
    wrpcap(pcap_file, packets)

    return result.stdout, result.stderr, duration, pcap_file

if __name__ == "__main__":
    playbook_install = "install_nginx.yml"
    playbook_revert = "revert_nginx.yml"
    inventory = "inventory.ini"
    
    install_durations = []
    revert_durations = []
    
    for i in range(10):
        stdout, stderr, duration, pcap_file = run_ansible_playbook(playbook_install, inventory, f"install_{i+1}")
        install_durations.append(duration)
        print(f"Run {i+1} Install Duration:", duration, "seconds")
        
        stdout, stderr, duration, pcap_file = run_ansible_playbook(playbook_revert, inventory, f"revert_{i+1}")
        revert_durations.append(duration)
        print(f"Run {i+1} Revert Duration:", duration, "seconds")
    
    print("Install Durations:", install_durations)
    print("Revert Durations:", revert_durations)
