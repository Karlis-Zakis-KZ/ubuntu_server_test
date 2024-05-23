import subprocess
import time
from scapy.all import sniff, wrpcap
import os

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

    # Calculate statistics
    num_packets = len(packets)
    file_size = os.path.getsize(pcap_file) / 1024  # in KB
    data_size = sum(len(pkt) for pkt in packets) / 1024  # in KB
    data_byte_rate = data_size / duration  # in KBps
    data_bit_rate = data_byte_rate * 8  # in kbps
    avg_packet_size = (data_size * 1024) / num_packets if num_packets > 0 else 0  # in bytes
    avg_packet_rate = num_packets / duration  # in packets/s

    return {
        "run": iteration,
        "duration": duration,
        "num_packets": num_packets,
        "file_size": file_size,
        "data_size": data_size,
        "data_byte_rate": data_byte_rate,
        "data_bit_rate": data_bit_rate,
        "avg_packet_size": avg_packet_size,
        "avg_packet_rate": avg_packet_rate
    }

if __name__ == "__main__":
    plan_deploy = "simple_puppet_bolt::deploy_app"
    inventory = "inventory.yaml"
    targets = "192.168.21.138"

    deploy_stats = []

    for i in range(10):
        deploy_stat = run_puppet_bolt_plan(plan_deploy, inventory, targets, f"deploy_{i+1}")
        deploy_stats.append(deploy_stat)
        print(f"Deploy Run {i+1} Stats:", deploy_stat)
    
    print("Deploy Stats:", deploy_stats)
