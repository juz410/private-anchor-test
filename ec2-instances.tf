locals {
  ssm_user_data = <<-EOF
                                #!/bin/bash
                                cd /tmp
                                yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
                                systemctl enable amazon-ssm-agent
                                systemctl start amazon-ssm-agent
                            EOF
}

locals {
  base_userdata = <<-EOF
#!/bin/bash
set -euxo pipefail

# Create journald forwarding directory
mkdir -p /var/log/journal-logs

# Create systemd service to forward journald logs
cat >/etc/systemd/system/journal-to-file.service <<'UNIT'
[Unit]
Description=Export journald to file for CloudWatch Agent
After=network.target

[Service]
ExecStart=/bin/bash -c 'journalctl -f -o short-iso >> /var/log/journal-logs/system.log'
Restart=always

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable --now journal-to-file.service

# CloudWatch Agent config
mkdir -p /opt/aws/amazon-cloudwatch-agent
cat >/opt/aws/amazon-cloudwatch-agent/config.json <<'JSON'
{
  "agent": { "metrics_collection_interval": 60, "run_as_user": "root" },
  "metrics": {
    "append_dimensions": { "InstanceId": "$${aws:InstanceId}" },
    "metrics_collected": {
      "mem": { "measurement": ["mem_used_percent"], "metrics_collection_interval": 60 },
      "disk": { "measurement": ["used_percent"], "metrics_collection_interval": 60, "resources": ["/"] }
    }
  },
  "logs": {
    "logs_collected": { "files": { "collect_list": [
      { "file_path": "/var/log/journal-logs/system.log",
        "log_group_name": "/ec2/${local.resource_name_prefix}/linux",
        "log_stream_name": "{instance_id}/journal" }
    ]}}
  }
}
JSON



/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/config.json -s

systemctl enable amazon-cloudwatch-agent
systemctl restart amazon-cloudwatch-agent
EOF

  ebs_userdata = <<-EOF
echo "Preparing and mounting extra EBS volume..."
DEV="/dev/nvme1n1"
if [ -b "$DEV" ]; then
  mkfs.xfs -f "$DEV" || mkfs.ext4 -F "$DEV"
  mkdir -p /DATA
  echo "$DEV /DATA xfs defaults,nofail 0 2" >> /etc/fstab || \
  echo "$DEV /DATA ext4 defaults,nofail 0 2" >> /etc/fstab
  mount -a
fi
EOF
}





locals {
  ec2_servers = {
    uat_server = {
      name_suffix        = "uat-server"
      ami                = data.aws_ami.amazon_linux.id
      instance_type      = "c7i.xlarge"
      subnet_id          = module.vpc.private_subnet_a_id
      security_group_ids = [module.security_groups.uat_server_sg_id]

      root_volume_size       = 100
      root_volume_iops       = 3000

      # Add one extra EBS volume
      ebs_block_devices = [
        {
          device_name           = "/dev/xvdb"
          volume_size           = 200
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 125
          encrypted             = true
          delete_on_termination = true
        }
      ]
      backup_8hourly  = false
      backup_12hourly  = true
      backup_daily   = false
      backup_weekly  = false
      backup_monthly = false
      backup_yearly = false
      user_data      = "${local.base_userdata}\n${local.ebs_userdata}"




    }

    all_in_one_server = {
      name_suffix            = "all-in-one-server"
      ami                    = data.aws_ami.amazon_linux.id
      instance_type          = "c7i.2xlarge"
      subnet_id              = module.vpc.private_subnet_a_id
      security_group_ids     = [module.security_groups.all_in_one_server_sg_id]
      root_volume_size       = 80
      root_volume_iops       = 3000

      # Add one extra EBS volume
      ebs_block_devices = [
        {
          device_name           = "/dev/xvdb"
          volume_size           = 80
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 125
          encrypted             = true
          delete_on_termination = true
        }
      ]
            user_data      = "${local.base_userdata}\n${local.ebs_userdata}"

    }
  }
}


# locals {
#   # Base setup for all instances (journald + CloudWatch agent)
#   base_userdata = <<-EOF
#    #!/bin/bash

#       # Create journald forwarding directory
#       mkdir -p /var/log/journal-logs

#       # Create systemd service to forward journald logs
#       cat <<EOC > /etc/systemd/system/journal-to-file.service
#       [Unit]
#       Description=Export journald to file for CloudWatch Agent
#       After=network.target

#       [Service]
#       ExecStart=/bin/bash -c 'journalctl -f -o short-iso >> /var/log/journal-logs/system.log'
#       Restart=always

#       [Install]
#       WantedBy=multi-user.target
#       EOC

#       # Reload and enable the journald export service
#       systemctl daemon-reload
#       systemctl enable --now journal-to-file.service

#       # Create CloudWatch Agent config file
#       cat <<EOCW > /opt/aws/amazon-cloudwatch-agent/config.json
#       {
#       "agent": {
#       "metrics_collection_interval": 60,
#       "run_as_user": "root"
#       },
#       "metrics": {
#       "append_dimensions": {
#       "InstanceId": "$${aws:InstanceId}"
#       },
#       "metrics_collected": {
#       "mem": {
#       "measurement": ["mem_used_percent"],
#       "metrics_collection_interval": 60
#       },
#       "disk": {
#       "measurement": ["used_percent"],
#       "metrics_collection_interval": 60,
#       "resources": ["/"]
#       }
#       }
#       },
#       "logs": {
#       "logs_collected": {
#       "files": {
#       "collect_list": [
#       {
#       "file_path": "/var/log/journal-logs/system.log",
#       "log_group_name": "/ec2/${var.global_prefix}/linux",
#       "log_stream_name": "{instance_id}/journal"
#       }
#       ]
#       }
#       }
#       }
#       }
#       EOCW

#       # Enable and start CloudWatch Agent
#       /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
#         -a fetch-config \
#         -m ec2 \
#         -c file:/opt/aws/amazon-cloudwatch-agent/config.json \
#         -s

#       systemctl enable amazon-cloudwatch-agent
#       systemctl restart amazon-cloudwatch-agent

#       EOF
  


#   # Optional script for instances that have an extra EBS volume
#   ebs_userdata = <<-EOF
#     echo "Preparing and mounting extra EBS volume..."
#     DEV="/dev/nvme1n1"
#     if [ -b "$DEV" ]; then
#       mkfs.xfs -f "$DEV" || mkfs.ext4 -F "$DEV"
#       mkdir -p /DATA
#       echo "$DEV /DATA xfs defaults,nofail 0 2" >> /etc/fstab || \
#       echo "$DEV /DATA ext4 defaults,nofail 0 2" >> /etc/fstab
#       mount -a
#     fi
#   EOF
# }