import subprocess
import time
from scapy.all import sniff, wrpcap, AsyncSniffer
import os
import logging

# Configure logging
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')

def run_bolt_plan(plan, targets, iteration, task_name):
    # Start packet sniffing
    logging.debug(f"Starting packet sniffing for {task_name} iteration {iteration}")
    sniffer = AsyncSniffer()
    sniffer.start()

    start_time = time.time()

    logging.debug(f"Running Puppet Bolt plan {plan} for {task_name} iteration {iteration}")
    result = subprocess.run(
        ["bolt", "plan", "run", plan, f"targets={targets}"],
        capture_output=True,
        text=True
    )

    end_time = time.time()
    duration = end_time - start_time

    # Stop packet sniffing
    packets = sniffer.stop()
    pcap_file = f"{task_name}_packets_{iteration}.pcap"
    wrpcap(pcap_file, packets)
    logging.debug(f"Packet sniffing stopped for {task_name} iteration {iteration}")

    num_packets = len(packets)
    file_size = os.path.getsize(pcap_file) / 1024  # in KB
    data_size = sum(len(pkt) for pkt in packets) / 1024  # in KB
    data_byte_rate = data_size / duration if duration > 0 else 0  # in KBps
    data_bit_rate = data_byte_rate * 8  # in kbps
    avg_packet_size = (data_size * 1024) / num_packets if num_packets > 0 else 0  # in bytes
    avg_packet_rate = num_packets / duration if duration > 0 else 0  # in packets/s

    logging.debug(f"Iteration {iteration} completed in {duration:.2f} seconds")
    logging.debug(f"STDOUT: {result.stdout}")
    logging.debug(f"STDERR: {result.stderr}")

    return {
        "run": iteration,
        "task": task_name,
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
    plan_deploy = "complex_bolt::deploy_app"
    plan_remove = "complex_bolt::remove_app"
    targets = "target_server"

    deploy_stats = []
    remove_stats = []

    for i in range(1, 4):  # Run a few iterations to test
        logging.debug(f"Deploy Run {i}")
        deploy_stat = run_bolt_plan(plan_deploy, targets, f"deploy_{i}", "deploy")
        deploy_stats.append(deploy_stat)

        logging.debug(f"Remove Run {i}")
        remove_stat = run_bolt_plan(plan_remove, targets, f"remove_{i}", "remove")
        remove_stats.append(remove_stat)

    logging.debug("Deploy Stats: %s", deploy_stats)
    logging.debug("Remove Stats: %s", remove_stats)

    print("Deploy Stats:", deploy_stats)
    print("Remove Stats:", remove_stats)
