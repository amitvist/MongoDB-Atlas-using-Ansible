# MongoDB Atlas Organization Creation via Ansible Automation Platform (AAP)

This repo is a tiny, production-friendly starter you can fork and plug into **Ansible Automation Platform** (or run locally)
to **create a MongoDB Atlas Organization** using the **Admin API**.

## What this does
- Creates an Atlas **Organization** using the endpoint `POST /api/atlas/v2/orgs`.
- Idempotent-ish behavior:
  - First tries to list accessible orgs and match by name.
  - If not found, attempts to create.
  - If API returns **409** (already exists), it reports *exists* gracefully.

> Note: Creating orgs via API typically requires an **Organization API Key** with sufficient privileges and an org that is **on a paid plan**.
> Also ensure your controller/executor IP is allowed in the **Admin API access list** in Atlas.

---

## Files
```
.
├─ playbooks/
│  └─ create_atlas_org.yml      # The Ansible playbook
├─ .env.example                 # Example env vars for local run
├─ run_local.sh                 # Helper script to run locally
└─ README.md                    # This file
```

---

## Quick start (local)
1. Copy `.env.example` to `.env` and fill in your keys:
   ```bash
   cp .env.example .env
   # edit .env and set:
   # export MONGODB_ATLAS_PUBLIC_KEY="xxxx"
   # export MONGODB_ATLAS_PRIVATE_KEY="xxxx"
   ```

2. (Optional) Create a Python venv and install Ansible if you don't already have `ansible`:
   ```bash
   python -m venv .venv && source .venv/bin/activate
   pip install ansible
   ```

3. Run the playbook:
   ```bash
   ./run_local.sh "My New Org Name"
   ```

You should see a final summary like:
```
Organization name: My New Org Name
Organization ID: <id or unknown>
Action: created | existing (no change) | exists (409)
```

---

## Use with Ansible Automation Platform (AAP)
1. **Create a Custom Credential Type** (UI → Access → Credential Types → Add)
   - **Name:** `MongoDB Atlas API Key`
   - **Inputs (YAML):**
     ```yaml
     fields:
       - id: atlas_public_key
         type: string
         label: Atlas Public Key
       - id: atlas_private_key
         type: string
         label: Atlas Private Key
         secret: true
     ```
   - **Injectors (YAML):**
     ```yaml
     env:
       MONGODB_ATLAS_PUBLIC_KEY: '{{ atlas_public_key }}'
       MONGODB_ATLAS_PRIVATE_KEY: '{{ atlas_private_key }}'
     ```

2. **Create a Credential** using that type and fill your keys.

3. **Create a Project** that points to this repo.

4. **Inventory:** use a simple `localhost` inventory in AAP.

5. **Job Template:**
   - Inventory: your localhost inventory
   - Project: this repo's project
   - Playbook: `playbooks/create_atlas_org.yml`
   - Credentials: the **MongoDB Atlas API Key** credential
   - **Extra Vars** (prompt on launch or default):
     ```yaml
     org_name: "My New Org Name"
     ```

6. **Launch** the job. Check the final summary in the stdout.

---

## Notes & troubleshooting
- **Unauthorized (401/403):** verify the key has correct org-level privileges and that your AAP/executor IP is in the **Admin API access list**.
- **409 exists:** means an org with the same constraints already exists. The playbook will report it and exit successfully.
- **Certificates / proxies:** keep `validate_certs: yes`. If behind a corporate proxy, configure environment variables accordingly.
- **Accept header:** defaults to `application/json`. You can switch to a versioned vendor header if you need strict API versions.

---

## License
Amit Yadav
