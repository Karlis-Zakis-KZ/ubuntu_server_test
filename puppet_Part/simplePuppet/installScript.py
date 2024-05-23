import subprocess
import time
from scapy.all import sniff, wrpcap

def run_puppet_bolt_plan(plan, inventory, targets, iteration):
    start_time = time.time()
    
    # Start sniffing packets
    packets = sniff(timeout=60)  # Adjust timeout based on expected duration
    
    # Run the Puppet Bolt plan
    result = subprocess.run(
        ["bolt", "plan", "run", plan, "--targets", targets, "--inventoryfile", inventory],
        capture_output=True,
        text=True
    )
    
    end_time = time.time()
    duration = end_time - start_time

    # Save captured packets to a file
    pcap_file = f"bolt_packets_{iteration}.pcap"
    wrpcap(pcap_file, packets)

    return result.stdout, result.stderr, duration, pcap_file

if __name__ == "__main__":
    plan_install = "install_nginx.pp"
    plan_revert = "revert_nginx.pp"
    inventory = "inventory.yaml"
    targets = "192.168.21.138"
    
    install_durations = []
    revert_durations = []
    
    for i in range(10):
        stdout, stderr, duration, pcap_file = run_puppet_bolt_plan(plan_install, inventory, targets, f"install_{i+1}")
        install_durations.append(duration)
        print(f"Run {i+1} Install Duration:", duration, "seconds")
        
        stdout, stderr, duration, pcap_file = run_puppet_bolt_plan(plan_revert, inventory, targets, f"revert_{i+1}")
        revert_durations.append(duration)
        print(f"Run {i+1} Revert Duration:", duration, "seconds")
    
    print("Install Durations:", install_durations)
    print("Revert Durations:", revert_durations)
