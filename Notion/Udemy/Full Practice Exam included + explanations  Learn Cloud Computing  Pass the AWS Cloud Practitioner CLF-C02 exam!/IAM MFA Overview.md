---
notion-id: 2ac5a6e2-1812-80b4-a082-d15a85af453e
---
## 1. 🔒 Password Policy

This is the first line of defense, designed to enforce strong passwords and protect against brute-force attacks. You can configure the following options:

- Set a **minimum password length**.
- Require specific **character types** (e.g., uppercase, lowercase, numbers, non-alphanumeric characters).
- Allow or prevent IAM users from changing their own passwords.
- Enforce **password expiration** (e.g., require users to change their password every 90 days).
- **Prevent password reuse** so users cannot use old passwords.

---

## 2. 🛡️ Multi-Factor Authentication (MFA)

MFA is described as a "must-have" second layer of security that should be enabled for the Root account and all IAM users.

- **What is MFA?** It's a security-enhancing mechanism that requires users to provide two forms of authentication:
    1. Something you **know** (your password).
    2. Something you **own** (a security device that generates a token).
- **The Benefit:** Even if a hacker steals or guesses your password, they will be unable to log in because they will not have your physical MFA device.

---

## 📱 MFA Device Options in AWS

The video lists four main types of MFA devices (note that most are provided by third parties):

1. **Virtual MFA Device**
    - A software-based solution using an app on your phone.
    - **Examples:** Google Authenticator or **Authy** (which is recommended for its multi-device support).
    - This is the method that will be used in the course's hands-on lab.
2. **U2F (Universal 2nd Factor) Security Key**
    - A physical USB device.
    - **Example:** A **YubiKey** (by Yubico).
    - A single key can be used for multiple root and IAM users.
3. **Hardware Key Fob MFA Device**
    - A small, physical hardware device that generates a code.
    - **Example:** Provided by third-party companies like **Gemalto**.
4. **Hardware Key Fob for AWS GovCloud**
    - A specialized key fob for use with the AWS US government cloud.
    - **Example:** Provided by a third-party like **SurePassID**.