# Azure Terraform with Workload Identity Federation

This repository demonstrates using Azure Workload Identity Federation with Terraform - **no secrets required**!

## 🔐 Azure Credentials

**App Registration Details:**
- Client ID: `abc`
- Tenant ID: `abc`
- Subscription ID: `abc`

## 📋 Prerequisites

1. Complete federated credential setup in Azure Portal
2. Add GitHub repository secrets

## 🚀 Setup

### 1. Add GitHub Secrets

Go to **Settings → Secrets and variables → Actions** and add:

- `AZURE_CLIENT_ID`: `abc`
- `AZURE_TENANT_ID`: `abc`
- `AZURE_SUBSCRIPTION_ID`: `abc`

### 2. Configure Federated Credential in Azure Portal

1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to **Azure Active Directory → App registrations**
3. Select app: **myapp**
4. Go to **Certificates & secrets → Federated credentials**
5. Click **Add credential**
6. Select **GitHub Actions deploying Azure resources**
7. Fill in:
   - Organization: `puneetbhatia77`
   - Repository: `workload-identity-federation-repo`
   - Entity type: `Branch`
   - Branch name: `main`
   - Name: `github-main-branch`
8. Click **Add**

### 3. Push to GitHub

```bash
cd my-repo
git init
git add .
git commit -m "Initial commit: Terraform with Workload Identity Federation"
git remote add origin https://github.com/puneetbhatia77/workload-identity-federation-repo.git
git branch -M main
git push -u origin main
```

The GitHub Actions workflow will automatically run and deploy resources!

## 📦 Resources Created

- **Resource Group**: `rg-myproject-dev` in East US
- **Storage Account**: `stmyprojectdev[hash]` with LRS replication

## 🔧 Local Development

For local testing (uses Azure CLI authentication):

```powershell
# Login to Azure
az login

# Navigate to repository
cd my-repo

# Run Terraform
terraform init
terraform plan -var-file="variables.tfvars"
terraform apply -var-file="variables.tfvars"
```

## 🎯 How It Works

1. **GitHub Actions** requests an OIDC token from GitHub
2. **Azure AD** validates the token using the federated credential configuration
3. **Azure AD** issues an access token for the service principal
4. **Terraform** uses the access token to deploy resources

## ✨ Benefits

✅ **No secrets stored** in GitHub - only IDs (public information)  
✅ **Automatic token rotation** - tokens expire quickly  
✅ **Enhanced security** - tokens tied to specific repository and branch  
✅ **Audit trail** - All authentication logged in Azure AD  
✅ **Zero maintenance** - No credential rotation required  

## 📂 Repository Structure

```
my-repo/
├── .github/
│   └── workflows/
│       └── terraform.yml    # GitHub Actions workflow
├── .gitignore              # Ignore Terraform state files
├── README.md               # This file
├── main.tf                 # Main Terraform configuration
└── variables.tfvars        # Variable values
```

## 🛠️ Workflow Features

- **Automatic runs** on push to `main` or pull requests
- **Manual trigger** available via workflow_dispatch
- **Terraform plan** on pull requests
- **Terraform apply** only on push to main
- **Terraform destroy** job (manual trigger with approval)

## 📖 Additional Resources

- [Azure Workload Identity Federation Documentation](https://docs.microsoft.com/en-us/azure/active-directory/develop/workload-identity-federation)
- [GitHub Actions OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📝 License

This project is provided as-is for demonstration purposes.
