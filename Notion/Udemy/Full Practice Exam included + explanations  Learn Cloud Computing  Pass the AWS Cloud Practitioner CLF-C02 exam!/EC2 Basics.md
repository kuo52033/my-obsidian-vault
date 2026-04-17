---
notion-id: 2ae5a6e2-1812-80fa-ba21-e7b1ebde728a
---
## 🖥️ What is Amazon EC2?

- **EC2** stands for **Elastic Compute Cloud**.
- It is one of the most popular AWS offerings and represents **Infrastructure as a Service (IaaS)**.
- Its core purpose is to allow you to **rent virtual machines** (called EC2 Instances) and compute power on-demand.

### Key Capabilities of EC2

EC2 is not just one service; it consists of several components:

- **Virtual Machines**: Renting the actual servers (EC2 Instances).
- **Storage**: Storing data on virtual drives (**EBS**) or hardware-attached drives (**EC2 Instance Store**).
- **Load Balancing**: Distributing load across machines (**ELB**).
- **Scaling**: Scaling services up or down (**Auto Scaling Group**).

---

## ⚙️ Configuration Options (Customizing your Instance)

When renting an EC2 instance, you have complete control over its configuration:

1. **Operating System (OS)**: Linux, Windows, or macOS.
2. **Compute Power**: Selection of CPU cores and processing power.
3. **RAM**: Amount of Random Access Memory.
4. **Storage Space**:
    - Network-attached storage (EBS or EFS).
    - Hardware-attached storage (EC2 Instance Store).
5. **Network Card**: Speed of the card and Public IP address type.
6. **Firewall Rules**: Managed via **Security Groups**.
7. **Bootstrap Script**: Configured via **EC2 User Data**.

---

## 🚀 EC2 User Data (Bootstrapping)

The video introduces the concept of **Bootstrapping**, which means launching commands automatically when the machine starts.

- **How it works**: You provide a script (User Data) that runs **only once** when the instance is first started.
- **Permissions**: The script runs with **root user** privileges (sudo).
- **Purpose**: It is used to automate boot tasks, such as:
    - Installing updates.
    - Installing software.
    - Downloading common files from the internet.