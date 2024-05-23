import subprocess
import time
from scapy.all import sniff, wrpcap

def run_puppet_bolt_plan(plan, inventory, targets):
    start_time = time.time()
    
    # Start sniffing packets
    packets = sniff(timeout=10)
    
    # Run the Puppet Bolt plan
    result = subprocess.run(
        ["bolt", "plan", "run", plan, "--targets", targets, "--inventoryfile", inventory],
        capture_output=True,
        text=True
    )
    
    end_time = time.time()
    duration = end_time - start_time

    # Save captured packets to a file
    wrpcap("bolt_packets.pcap", packets)

    return result.stdout, result.stderr, duration

if __name__ == "__main__":
    plan = "revert_nginx.pp"
    inventory = "inventory.yaml"
    targets = "192.168.21.138"
    stdout, stderr, duration = run_puppet_bolt_plan(plan, inventory, targets)

    print("STDOUT:", stdout)
    print("STDERR:", stderr)
    print("Duration:", duration, "seconds")
