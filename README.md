
# Automating your C2 infra 

---

![iac-c2](https://i.imgur.com/OSRNZ8f.png)

---


## Pre-req

* Digital Ocean token (get it from settings-> API)
* terraform installed in your local machine
* SSH key pair 
* cloudflare token, zone id
* basic mind-set

Create a terraform.tfvars file with the following variables:
* cloudflare_zone = "" - refers to the domain zone_id in cloudflare
* cloudflare_token= "" - cloudflare global api token
* cloudflare_email= "" - your cloudflare email id
* do_token = "" - DO token
