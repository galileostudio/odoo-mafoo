# Odoo Image Builder with Packer

This directory contains Packer configuration to build a custom Odoo image on Google Cloud Platform.

## Prerequisites

1. Install [Packer](https://www.packer.io/downloads)
2. Install [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
3. Authenticate with GCP:
   ```bash
   gcloud auth application-default login
   ```

## Directory Structure

```
packer/
├── odoo.pkr.hcl       # Main Packer configuration
├── variables.pkr.hcl  # Variable definitions
└── scripts/
    └── setup-odoo.sh  # Script to install and configure Odoo
```

## Usage

1. Initialize Packer plugins:
   ```bash
   packer init .
   ```

2. Validate the configuration:
   ```bash
   packer validate -var 'project_id=your-project-id' .
   ```

3. Build the image:
   ```bash
   packer build -var 'project_id=your-project-id' .
   ```

## Variables

You can override default variables using the `-var` flag or by creating a `variables.auto.pkrvars.hcl` file.

| Variable | Description | Default |
|----------|-------------|---------|
| `project_id` | GCP Project ID | (required) |
| `source_image_family` | Source image family | `debian-11` |
| `zone` | GCP zone | `us-central1-a` |
| `image_name` | Output image name | `odoo-production-ready` |
| `image_family` | Image family name | `odoo-production` |
| `machine_type` | Instance type for build | `e2-medium` |

## First Boot

On first boot, the image will:
1. Generate a random admin password
2. Configure Odoo with the new password
3. Start the Odoo service

## Notes

- The image will be created in the `global/images` folder of your GCP project
- The admin password will be stored in the Odoo configuration file at `/etc/odoo.conf`
- Odoo will be accessible on port 8069

## License

This project is licensed under the MIT License.
