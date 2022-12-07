Turn The Bus Customization Notes
================================

- Note that i created a dummy AWS Route53 hosted zone for turnthebus.org. Cookiecutter references the HostedZoneId of this dummy zone to bootstrap the creation of the environment zones. It also adds stack-level DNS entries for bastion, mongodb, etcetera. I manually copied these Cookiecutter-generated records to the real DNS host at DreamHost.com
