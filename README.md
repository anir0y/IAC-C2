
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


---

## Contribute

you can cotribute on porting the code from `Digital Ocean` to `AWS`, `Azure` and `GCP`. to support all major Cloud platforms. 

## Bug report 

send your bug report to [@anir0y](https://twitter.com/anir0y) [@Vatsal](https://twitter.com/vatsal_mob)
