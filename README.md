This code will provision below resources in azure:
1. Resource Group
2. Vnet and Subnet
3. LoadBalancer
4. LB Rule and NAT rule
5. VMSS with 2 machines 
6. Ansible playbook to install apache server on to VMs part of VMSS


Area of improvement in the code:

1. Adding more variables for reuse
2. Use of local in some places to decrease the number of lines.
3. Code could be modularized to ease use while executing with different options
4. The infra could be improved enabling high availability, multiAZ etc.
5. The VMSS could have dynamic rollout policy enabled instead of just manual for scaling out and scaling in.
6. The code could have been placed in github and called it using terraform enterprise cloud and store all credentials in terraform cloud
7. Could make use of azure vault to store all credentials
9. All best practices are not met
10. Workspaces can be used for deploying in to multiple environment with condition
11. AD user creation and granting permission to VMSS is not considered


I can discuss all other points during discussion.

Created custom modules for few resources to showcase
