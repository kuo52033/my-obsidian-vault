---
notion-id: 2af5a6e2-1812-807e-b8fc-db08095f52b1
---
Connecting to EC2 instances—especially Linux instances—is one of the most common tasks and also one of the trickiest parts for new AWS users. This section explains the different ways you can connect to an EC2 instance and what you should know for the exam.

---

## **1. Why We Need SSH**

For Linux EC2 instances, you use **SSH (Secure Shell)** to securely connect and perform actions such as:

- troubleshooting
- maintenance
- installing packages
- accessing logs

SSH provides encrypted, command-line access over the network.

---

# **2. Different Connection Methods**

Different operating systems use different tools to perform SSH.

---

## **(A) macOS & Linux**

These systems include SSH by default.

You can simply run:

```bash
ssh -i my-key.pem ec2-user@<EC2-Public-IP>


```

⚠ **Exam Tip**:

You *must* use a **private key (.pem file)** that matches the key pair used when launching the instance.

---

## **(B) Windows (before Windows 10)**

Older Windows versions do not include SSH.

They use:

### **PuTTY**

- A free Windows SSH client.
- Requires converting your `.pem` file into `.ppk` (PuTTY format).

PuTTY works on **all** Windows versions.

---

## **(C) Windows 10+**

Modern Windows includes the same SSH utility as macOS/Linux.

So you can run the same command:

```powershell
ssh -i my-key.pem ec2-user@<EC2-Public-IP>


```

---

## **(D) EC2 Instance Connect (Browser-based)**

This is the easiest and increasingly recommended way.

### **Features**

- Works in **Chrome, Edge, Safari, Firefox**
- Works on **Mac, Windows, Linux**
- No need to install anything
- No need to deal with keys manually
- SSH directly in your browser

### **Limitation**

Currently supports:

- **Amazon Linux 2**
- **Some Amazon Linux–based AMIs**

⚠ **Exam Tip:**

EC2 Instance Connect dynamically pushes a **temporary SSH key** into the instance metadata.

---

# **3. Common Issues with SSH (Very Important!)**

SSH is the #1 source of student mistakes.

Typical causes:

### **❌ Wrong security group rules**

You must allow:

```plain text
Inbound:
Protocol: TCP
Port: 22
Source: Your IP address


```

If port 22 is not open → You get a **timeout**.

### **❌ Wrong username**

Different AMIs use different default users:

| AMI Type | Username |
| --- | --- |
| Amazon Linux 2 | `ec2-user` |
| Ubuntu | `ubuntu` |
| Debian | `admin` |
| RHEL | `ec2-user` |
| CentOS | `centos` |

### **❌ Wrong key permission**

Your `.pem` file must not be publicly visible:

```bash
chmod 400 my-key.pem


```

### **❌ Wrong key pair**

If you used the wrong key pair when launching the instance → SSH will fail.

---

# **4. Troubleshooting Strategy**

The instructor provides a troubleshooting guide.

General flow:

1. Check security group allows port 22 from your IP
2. Confirm correct key file
3. Confirm correct username
4. Ensure the instance has a public IP
5. Try **EC2 Instance Connect** (often fixes everything)

---

# **5. What You Should Know for the Exam**

The exam does **not** require you to run SSH commands, but you must understand concepts:

### ✔ You connect to Linux using SSH on **port 22**.

### ✔ EC2 Instance Connect provides browser-based SSH access.

### ✔ You need the **private key** to establish SSH connection.

### ✔ Security Group must allow inbound **TCP 22**.

### ✔ If connection = timeout → Security Group issue.

### ✔ If connection refused → App/instance issue (not SG).

### ✔ Windows can use PuTTY (older versions) or built-in SSH (Win10+).