import subprocess
import time
from scapy.all import sniff, wrpcap
import os

def run_ansible_playbook(playbook, inventory, iteration):
    start_time = time.time()

    # Start sniffing packets
    packets = sniff(timeout=1800)  # Adjust timeout based on expected duration

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
    playbook_deploy = "deploy_app.yml"
    playbook_remove = "remove_app.yml"
    inventory = "inventory.ini"

    deploy_stats = []
    remove_stats = []

    for i in range(10):
        deploy_stat = run_ansible_playbook(playbook_deploy, inventory, f"deploy_{i+1}")
        deploy_stats.append(deploy_stat)
        print(f"Deploy Run {i+1} Stats:", deploy_stat)

        remove_stat = run_ansible_playbook(playbook_remove, inventory, f"remove_{i+1}")
        remove_stats.append(remove_stat)
        print(f"Remove Run {i+1} Stats:", remove_stat)
    
    print("Deploy Stats:", deploy_stats)
    print("Remove Stats:", remove_stats)
