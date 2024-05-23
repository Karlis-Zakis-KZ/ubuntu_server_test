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
    plan_install = "simple_puppet_bolt::install_nginx"
    plan_revert = "simple_puppet_bolt::revert_nginx"
    inventory = "inventory.yaml"
    targets = "192.168.21.138"

    install_stats = []
    revert_stats = []

    for i in range(10):
        install_stat = run_puppet_bolt_plan(plan_install, inventory, targets, f"install_{i+1}")
        install_stats.append(install_stat)
        print(f"Install Run {i+1} Stats:", install_stat)

        revert_stat = run_puppet_bolt_plan(plan_revert, inventory, targets, f"revert_{i+1}")
        revert_stats.append(revert_stat)
        print(f"Revert Run {i+1} Stats:", revert_stat)
    
    print("Install Stats:", install_stats)
    print("Revert Stats:", revert_stats)
